const escapeHtml = (value) => value.replace(/</g, '&lt;').replace(/>/g, '&gt;');

const escapeAttribute = (value) => escapeHtml(value).replace(/"/g, '&quot;');

export function renderInline(text) {
    const codeSpans = [];

    let result = text.replace(/`([^`]+)`/g, (_, code) => {
        codeSpans.push(`<code>${escapeHtml(code)}</code>`);
        return `\u0000CODE${codeSpans.length - 1}\u0000`;
    });

    result = escapeHtml(result);

    result = result.replace(
        /\[([^\]]+)\]\(([^)\s]+)\)/g,
        (_, label, url) => `<a href="${escapeAttribute(url)}" target="_blank" rel="noopener noreferrer">${label}</a>`,
    );

    result = result.replace(/\*\*([^*]+)\*\*/g, '<strong>$1</strong>');
    result = result.replace(/__([^_]+)__/g, '<strong>$1</strong>');
    result = result.replace(/(^|[^*])\*([^*\n]+)\*/g, '$1<em>$2</em>');
    result = result.replace(/(^|[^_])_([^_\n]+)_/g, '$1<em>$2</em>');

    return result.replace(/\u0000CODE(\d+)\u0000/g, (_, index) => codeSpans[Number(index)]);
}

const listItemPattern = /^(\s*)([-*+]|\d+[.)])\s+(.*)$/;

function splitTableRow(line) {
    let row = line.trim();

    if (row.startsWith('|')) {
        row = row.slice(1);
    }

    if (row.endsWith('|')) {
        row = row.slice(0, -1);
    }

    return row.split('|').map((cell) => cell.trim());
}

function isTableSeparator(line) {
    if (!line || !line.includes('|')) {
        return false;
    }

    const stripped = line.replace(/[|\s]/g, '');

    return stripped.includes('-') && /^[-:]+$/.test(stripped);
}

function isTableStart(lines, index) {
    return (
        lines[index]?.includes('|') &&
        index + 1 < lines.length &&
        isTableSeparator(lines[index + 1])
    );
}

function tableAlignment(cell) {
    const trimmed = cell.trim();

    if (trimmed.startsWith(':') && trimmed.endsWith(':')) {
        return 'center';
    }

    if (trimmed.endsWith(':')) {
        return 'right';
    }

    return 'left';
}

function parseList(lines, start) {
    const baseIndent = lines[start].match(/^(\s*)/)[1].length;
    const ordered = /^\s*\d+[.)]\s+/.test(lines[start]);
    const items = [];

    let index = start;

    while (index < lines.length) {
        const line = lines[index];

        if (!line.trim()) {
            let next = index + 1;

            while (next < lines.length && !lines[next].trim()) {
                next += 1;
            }

            const nextMatch = lines[next]?.match(listItemPattern);

            if (nextMatch && nextMatch[1].length >= baseIndent) {
                index = next;
                continue;
            }

            break;
        }

        const match = line.match(listItemPattern);

        if (!match && line.trim().startsWith('```')) {
            const indent = line.match(/^(\s*)/)[1].length;
            const code = [];

            index += 1;

            while (index < lines.length && !lines[index].trim().startsWith('```')) {
                code.push(lines[index].replace(new RegExp(`^\\s{0,${indent}}`), ''));
                index += 1;
            }

            index += 1;

            if (items.length > 0) {
                items[items.length - 1].children.push(
                    `<pre><code>${escapeHtml(code.join('\n'))}</code></pre>`,
                );
                continue;
            }

            break;
        }

        if (!match) {
            if (items.length > 0) {
                items[items.length - 1].content += ` ${line.trim()}`;
                index += 1;
                continue;
            }

            break;
        }

        const indent = match[1].length;

        if (indent < baseIndent) {
            break;
        }

        if (indent > baseIndent) {
            if (items.length === 0) {
                break;
            }

            const [nestedHtml, nextIndex] = parseList(lines, index);
            items[items.length - 1].children.push(nestedHtml);
            index = nextIndex;
            continue;
        }

        items.push({ content: match[3], children: [] });
        index += 1;
    }

    const tag = ordered ? 'ol' : 'ul';
    const body = items
        .map((item) => `<li>${renderInline(item.content)}${item.children.join('')}</li>`)
        .join('');

    return [`<${tag}>${body}</${tag}>`, index];
}

function isBlockStart(lines, index) {
    const line = lines[index];

    if (!line.trim()) {
        return true;
    }

    return (
        /^#{1,6}\s+/.test(line) ||
        /^```/.test(line) ||
        /^>\s?/.test(line) ||
        /^\s*(---|\*\*\*|___)\s*$/.test(line) ||
        listItemPattern.test(line) ||
        isTableStart(lines, index)
    );
}

function renderBlocks(lines) {
    let html = '';
    let index = 0;

    while (index < lines.length) {
        const line = lines[index];

        if (!line.trim()) {
            index += 1;
            continue;
        }

        if (/^```/.test(line)) {
            const code = [];
            index += 1;

            while (index < lines.length && !/^```/.test(lines[index])) {
                code.push(lines[index]);
                index += 1;
            }

            index += 1;
            html += `<pre><code>${escapeHtml(code.join('\n'))}</code></pre>`;
            continue;
        }

        const heading = line.match(/^(#{1,6})\s+(.+?)\s*#*\s*$/);

        if (heading) {
            const level = heading[1].length;
            html += `<h${level}>${renderInline(heading[2])}</h${level}>`;
            index += 1;
            continue;
        }

        if (/^\s*(---|\*\*\*|___)\s*$/.test(line)) {
            html += '<hr />';
            index += 1;
            continue;
        }

        if (/^>\s?/.test(line)) {
            const quoted = [];

            while (index < lines.length && /^>\s?/.test(lines[index])) {
                quoted.push(lines[index].replace(/^>\s?/, ''));
                index += 1;
            }

            html += `<blockquote>${renderBlocks(quoted)}</blockquote>`;
            continue;
        }

        if (isTableStart(lines, index)) {
            const header = splitTableRow(line);
            const alignments = splitTableRow(lines[index + 1]).map(tableAlignment);
            const rows = [];

            index += 2;

            while (index < lines.length && lines[index].includes('|') && lines[index].trim()) {
                rows.push(splitTableRow(lines[index]));
                index += 1;
            }

            const head = header
                .map(
                    (cell, cellIndex) =>
                        `<th style="text-align:${alignments[cellIndex] ?? 'left'}">${renderInline(cell)}</th>`,
                )
                .join('');

            const body = rows
                .map(
                    (row) =>
                        `<tr>${header
                            .map(
                                (_, cellIndex) =>
                                    `<td style="text-align:${alignments[cellIndex] ?? 'left'}">${renderInline(
                                        row[cellIndex] ?? '',
                                    )}</td>`,
                            )
                            .join('')}</tr>`,
                )
                .join('');

            html += `<div class="md-table-wrap"><table><thead><tr>${head}</tr></thead><tbody>${body}</tbody></table></div>`;
            continue;
        }

        if (listItemPattern.test(line)) {
            const [listHtml, nextIndex] = parseList(lines, index);
            html += listHtml;
            index = nextIndex;
            continue;
        }

        const paragraph = [];

        while (index < lines.length && lines[index].trim() && !isBlockStart(lines, index)) {
            paragraph.push(lines[index].trim());
            index += 1;
        }

        if (paragraph.length > 0) {
            html += `<p>${renderInline(paragraph.join(' '))}</p>`;
        }
    }

    return html;
}

export function renderMarkdown(markdown) {
    if (!markdown) {
        return '';
    }

    return renderBlocks(markdown.replace(/\r\n/g, '\n').split('\n'));
}
