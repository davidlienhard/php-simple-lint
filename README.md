# PHP Simple Lint
Simple PHP Lint Action using a shell script

This requires PHP already to be set up in the workflow.

## Inputs

### `folder`

The folder to control. Defaults to `"./"`.

### `ignore`

Semicolon separated list of folders or files to ignore. Special caracters like asterisks or semicolons must be escaped.

`ignore: './vendor/\*'` or `ignore: './vendor/\*\;./tests/\*'`

Defaults to `'./vendor/\*'`

## Example usage

```yaml
- name: PHP Simple Lint
  uses: davidlienhard/php-simple-lint@1
  with:
    folder: './'
    ignore: './vendor/\*'
```
