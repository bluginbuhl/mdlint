#!/usr/bin/env bash

# Linter-style Markdown checker: flags lines >MAX_LINE_LENGTH chars and
# trailing whitespace, with exception for long hyperlinks in Markdown

# Config
MAX_LINE_LENGTH=88
IGNORE_DIRS=".git .venv build dist"

EXIT_CODE=0

# Colors for output
RED='\033[0;31m'
CYAN='\033[0;34m'
NC='\033[0m'

# Space-separated list of directory names to ignore (matches anywhere in path)

# Construct find command to exclude paths containing ignored directories
FIND_CMD='find . -type f -name "*.md"'
for dir in $IGNORE_DIRS; do
  FIND_CMD+=" ! -path \"*/$dir/*\""
done

# Execute
while read -r file; do
  LINE_NUM=0
  while IFS= read -r line || [[ -n "$line" ]]; do
    LINE_NUM=$((LINE_NUM + 1))

    if [[ ${#line} -gt ${MAX_LINE_LENGTH} ]]; then
      # Skip long lines if overflow is due to Markdown hyperlink
      if [[ "$line" =~ \[.*\]\(.*\) ]]; then
        markdown_links=$(grep -oP '\[.*?\]\(.*?\)' <<< "$line")
        skip_line=0
        while read -r link; do
          link_start=$(awk -v a="$line" -v b="$link" 'BEGIN{print index(a,b)}')
          if [[ $link_start -eq 0 ]]; then
            continue
          fi
          link_end=$((link_start + ${#link} - 1))
          if (( MAX_LINE_LENGTH >= link_start && MAX_LINE_LENGTH <= link_end )); then
            skip_line=1
            break
          fi
        done <<< "$markdown_links"

        if (( skip_line == 1 )); then
          continue
        fi
      fi

      line_over=$((MAX_LINE_LENGTH + 1))
      CODE_POS="${file}${CYAN}:${NC}${LINE_NUM}${CYAN}:${NC}${line_over}${CYAN}:"
      MSG_TYPE="${RED} E501${NC}"
      MSG_TEXT="Line too long (${#line} > ${MAX_LINE_LENGTH} characters)"
      echo -e "${CODE_POS}${MSG_TYPE} ${MSG_TEXT}"
      EXIT_CODE=1
    fi

    if [[ "$line" =~ [[:blank:]]$ ]]; then
      trimmed_len=$(echo -n "$line" | sed -E 's/[[:blank:]]+$//' | wc -c)
      trailing_col=$((trimmed_len + 1))
      CODE_POS="${file}${CYAN}:${NC}${LINE_NUM}${CYAN}:${NC}${trailing_col}${CYAN}:"
      MSG_TYPE="${RED} W209${NC}"
      MSG_TEXT="Trailing whitespace"
      echo -e "${CODE_POS}${MSG_TYPE} ${MSG_TEXT}"
      EXIT_CODE=1
    fi
  done < "$file"
done < <(eval $FIND_CMD)

exit $EXIT_CODE
