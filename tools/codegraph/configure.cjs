const fs = require('node:fs');
const path = require('node:path');
const { randomUUID } = require('node:crypto');
const { isDeepStrictEqual } = require('node:util');
const { applyEdits, modify, parseTree, findNodeAtLocation, getNodeValue } = require('jsonc-parser');

const serverPath = ['mcp', 'servers', 'codegraph'];
const server = { type: 'local', command: ['codegraph', 'serve', '--mcp'], codemode: false };

function readConfig(file) {
    const text = fs.readFileSync(file, 'utf8');
    const bom = text.startsWith('\uFEFF') ? '\uFEFF' : '';
    const body = text.slice(bom.length);
    const errors = [];
    const tree = parseTree(body, errors, { allowTrailingComma: true });
    if (errors.length || tree?.type !== 'object') {
        throw new Error(`JSONC inválido en ${file}.`);
    }
    return { file, bom, body, tree };
}

function checkServer({ file, tree }) {
    for (const key of [['mcp'], ['mcp', 'servers']]) {
        const node = findNodeAtLocation(tree, key);
        if (node && node.type !== 'object') {
            throw new Error(`Configuración incompatible de ${key.join('.')} en ${file}.`);
        }
    }
    if (findNodeAtLocation(tree, ['mcp', 'codegraph'])) {
        throw new Error(`Migra mcp.codegraph a mcp.servers.codegraph en ${file}.`);
    }
    const node = findNodeAtLocation(tree, serverPath);
    if (!node) return false;

    const existing = getNodeValue(node);
    const { disabled, ...settings } = existing ?? {};
    if ((disabled !== undefined && disabled !== false) || !isDeepStrictEqual(settings, server)) {
        throw new Error(`Ya existe una entrada CodeGraph incompatible en ${file}.`);
    }
    return true;
}

function configure(target, otherFiles, checkOnly) {
    const files = [target, ...otherFiles].filter(file => fs.existsSync(file));
    const configs = files.map(readConfig);
    const alreadyConfigured = configs.map(checkServer).some(Boolean);
    if (alreadyConfigured || checkOnly) return;

    const { bom, body } = configs.find(config => config.file === target) ?? { bom: '', body: '{}\n' };
    const eol = body.includes('\r\n') ? '\r\n' : '\n';
    const indent = body.match(/(?:^|\n)([ \t]+)"/)?.[1] ?? '  ';
    const edits = modify(body, serverPath, server, {
        formattingOptions: { eol, insertSpaces: !indent.includes('\t'), tabSize: indent.length },
    });
    const result = applyEdits(body, edits);
    const errors = [];
    const tree = parseTree(result, errors, { allowTrailingComma: true });
    if (errors.length || !checkServer({ file: target, tree })) {
        throw new Error(`No se pudo validar el JSONC generado para ${target}.`);
    }
    const temporary = path.join(path.dirname(target), `.harness-${randomUUID()}.tmp`);
    fs.writeFileSync(temporary, bom + result, { flag: 'wx' });
    try {
        fs.renameSync(temporary, target);
    } finally {
        fs.rmSync(temporary, { force: true });
    }
}

try {
    const [target, ...options] = process.argv.slice(2);
    if (!target) throw new Error('Falta la ruta de configuración.');
    configure(target, options.filter(option => option !== '--check'), options.includes('--check'));
} catch (error) {
    console.error(error.message);
    process.exitCode = 1;
}
