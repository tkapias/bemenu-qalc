#!/usr/bin/env bash

#########################
# bemenu-qalc
#
# Licence: GNU GPLv3
# Author: Tomasz Kapias
#
# Dependencies:
#   bemenu v0.6.23
#   bemenu-orange-wrapper
#   Nerd-Fonts
#   xclip
#   qalc
#   qalculate-gtk
#   bash
#
#########################

# bemenu-qalc does not use any arguments

# file operations history with results
history_file="$HOME/.local/state/bemenu-qalc-history.txt"

# bemenu keybindings, defaults and vim mode
define(){ IFS=$'\n' read -r -d '' "${1}" || true; }
keybindings=""
define keybindings <<- 'HEREDOC'
	#  bemenu-qalc starts in insert mode
	Left		INSR:	Move cursor left
	Right		INSR:	Move cursor right
	Up		INSR:	Move to previous item
	Down		INSR:	Move to next item
	Shift + Left	INSR:	Select previous item
	Shift + Right	INSR:	Select next item
	Shift + Alt + <	INSR:	Select first item in actual list
	Shift + Alt + >	INSR:	Select last item in actual list
	Shift + PgUp	INSR:	Select first item in actual list
	Shift + PgDown	INSR:	Select last item in actual list
	Page Up		INSR:	Select first item in displayed list
	Page Down	INSR:	Select last item in displayed list
	Tab		INSR:	Move to next item
	Shift + Tab	INSR:	Select item and place it in filter
	Esc		INSR:	Exit insert mode, second time: Exit bemenu
	Insert		INSR:	Return filter text or selected items if multi selection
	Shift + Return	INSR:	Return filter text or selected items if multi selection
	Return		INSR:	Execute selected item
	Home		INSR:	Curses cursor set to 0
	End		INSR:	Cursor set to end of filter text
	Backspace	INSR:	Delete character at cursor
	Delete		INSR:	Delete character at cursor
	Delete Left	INSR:	Delete text before cursor
	Delete Right	INSR:	Delete text after cursor
	Word Delete	INSR:	Delete all text in filter
	Alt + v		INSR:	Select last item in displayed list
	Alt + j		INSR:	Select next item
	Alt + d		INSR:	Select last item in display list
	Alt + l		INSR:	Select previous item
	Alt + f		INSR:	Select next item
	Alt + 0-9	INSR:	Execute selected item with custom exit code
	Ctrl + Return	INSR:	Select item but don't quit to select multiple items
	Ctrl + g	INSR:	Exit bemenu
	Ctrl + n	INSR:	Select next item
	Ctrl + p	INSR:	Select previous item
	Ctrl + a	INSR:	Move cursor to beginning of text in filter
	Ctrl + e	INSR:	Move cursor to end of text in filter
	Ctrl + h	INSR:	Delete character at cursor
	Ctrl + u	INSR:	Kill text behind cursor
	Ctrl + k	INSR:	Kill text after cursor
	Ctrl + w	INSR:	Kill all text in filter
	Ctrl + m	INSR:	Execute selected item
	Ctrl + y	INSR:	Paste clipboard
	j/n		NORM:	Goto next item
	k/p		NORM:	Goto previous item
	h		NORM:	Move cursor left
	l		NORM:	Move cursor right
	q		NORM:	Quit bemenu
	v		NORM:	Toggle item selection
	i		NORM:	Enter insert mode
	I		NORM:	Move to line start and enter insert mode
	a		NORM:	Move to the right and enter insert mode
	A		NORM:	Move to line end and enter insert mode
	w		NORM:	Move a word
	b		NORM:	Move a word backwards
	e		NORM:	Move to end of word
	x		NORM:	Delete a character
	X		NORM:	Delete a character before the cursor
	0		NORM:	Move to line start
	$		NORM:	Move to line end
	gg		NORM:	Goto first item
	G		NORM:	Goto last item
	H		NORM:	Goto first item in view
	M		NORM:	Goto middle item in view
	L		NORM:	Goto last item in view
	F		NORM:	Scroll one page of items down
	B		NORM:	Scroll one page of items up
	dd		NORM:	Delete the whole line
	dw		NORM:	Delete a word
	db		NORM:	Delete a word backwards
	d0		NORM:	Delete to start of line
	d$		NORM:	Delete to end of line
	cc		NORM:	Change the whole line
	cw		NORM:	Change a word
	cb		NORM:	Change a word backwards
	c0		NORM:	Change to start of line
	c$		NORM:	Change to end of line
HEREDOC

help=""
answer=""

# create a list: last opération + header menu + history
get_history() {
  if [[ -n "$help" ]]; then
    echo -e "󰜉 return"
    echo "$keybindings"
  else
    [[ ! -f "$history_file" ]] && mkdir -p "$(dirname "$history_file")" && touch "$history_file"
    if [[ ! -s "$history_file" ]]; then
      echo -e "󰋚 no history found\n󰈆 open gui\n󰌌 keybindings"
    else
      if [[ -n "$answer" ]]; then
        echo -n "󰇽 "; tac "$history_file" | head -1
      fi
      echo -e "󰇾 clear\n󰆏 copy\n󰜉 history reset\n󰈆 open gui\n󰌌 keybindings"
      tac "$history_file"
    fi
  fi
}

while
  input=$(get_history | bemenu -p " = $answer")
  [[ -n "$input" ]] # exit if bemenu quit
do
  if [[ "$input" =~ clear$|return$|found$ ]]; then
    answer=""
    help=""
  elif [[ "$input" =~ ^󰇽 ]]; then
    input="$answer"
  elif [[ "$input" =~ copy$ ]]; then
    echo "$answer" | xclip -sel clip
  elif [[ "$input" =~ reset$ ]]; then
    truncate -s 0 "$history_file"
    answer=""
  elif [[ "$input" =~ gui$ ]]; then
    qalculate-gtk "$answer" &
    exit
  elif [[ "$input" =~ keybindings$ ]]; then
    help=1
  else
    input="$answer$input"
    answer=$(qalc +u8 -color=never --terse "$input" 2> /dev/null)
    echo "$input = $answer" >> "$history_file"
  fi
done
