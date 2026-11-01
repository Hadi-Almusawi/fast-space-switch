#!/usr/bin/env python3
"""Check static pages and release details without installing the app."""
import json
import pathlib
import plistlib
import shutil
import subprocess
import xml.etree.ElementTree as ET
from html.parser import HTMLParser
from urllib.parse import urlsplit

ROOT = pathlib.Path(__file__).resolve().parents[1]
SITE = ROOT / 'docs'
BASE = 'https://hadi-almusawi.github.io/fast-space-switch/'

class Page(HTMLParser):
    def __init__(self):
        super().__init__()
        self.tags = []
        self.schema = ''
        self.in_schema = False
    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        self.tags.append((tag, attrs))
        if tag == 'script' and attrs.get('type') == 'application/ld+json':
            self.in_schema = True
    def handle_endtag(self, tag):
        if tag == 'script':
            self.in_schema = False
    def handle_data(self, data):
        if self.in_schema:
            self.schema += data

for file in SITE.glob('*.html'):
    text = file.read_text()
    page = Page()
    page.feed(text)
    assert sum(tag == 'h1' for tag, _ in page.tags) == 1, file
    assert any(tag == 'meta' and attrs.get('name') == 'description' for tag, attrs in page.tags), file
    assert any(tag == 'link' and attrs.get('rel') == 'canonical' and attrs['href'].startswith(BASE) for tag, attrs in page.tags), file
    ids = [attrs['id'] for _, attrs in page.tags if 'id' in attrs]
    assert len(ids) == len(set(ids)), file
    for tag, attrs in page.tags:
        for key in ('href', 'src'):
            url = attrs.get(key, '')
            parsed = urlsplit(url)
            if parsed.scheme or parsed.netloc or not url:
                continue
            target = SITE / parsed.path if parsed.path else file
            if target.is_dir():
                target /= 'index.html'
            assert target.exists(), (file, url)
            if parsed.fragment and target == file:
                assert parsed.fragment in ids, (file, url)
        if tag == 'script' and attrs.get('src'):
            assert not urlsplit(attrs['src']).scheme, 'External script'
    if page.schema:
        schema = json.loads(page.schema)
        app = next(item for item in schema['@graph'] if item['@type'] == 'SoftwareApplication')
        assert app['operatingSystem'] == 'macOS 26'
        assert app['offers']['price'] == '0'
        assert 'aggregateRating' not in app
    assert not any(word in text.lower() for word in ('google-analytics', 'googletagmanager'))
    assert '\u2014' not in text and '\u2013' not in text
    print(f'PASS {file.relative_to(ROOT)}: metadata, headings, local links, data')

tree = ET.parse(SITE / 'sitemap.xml')
assert len(tree.findall('{*}url')) == 3
for loc in tree.findall('.//{*}loc'):
    assert loc.text.startswith(BASE)
    assert (SITE / (loc.text.removeprefix(BASE) or 'index.html')).exists()
with (ROOT / 'Info.plist').open('rb') as handle:
    assert plistlib.load(handle)['CFBundleShortVersionString'] == '1.1.2'
for script in ('install.sh', 'uninstall.sh', 'scripts/package.sh'):
    subprocess.run([shutil.which('zsh') or 'bash', '-n', str(ROOT / script)], check=True)
subprocess.run(['git', 'diff', '--check'], cwd=ROOT, check=True)
print('PASS sitemap, app version, shell syntax, diff')
print('These checks do not test desktop switching, Gatekeeper, or page appearance.')
