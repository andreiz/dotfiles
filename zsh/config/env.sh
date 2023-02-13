export PATH=$PATH:~/Applications/Argyll_V2.1.2/bin:~/Library/Python/3.9/bin

export EDITOR=vim

export FD_OPTIONS="--follow --hidden --exclude .git --exclude node_modules"

export FZF_DEFAULT_OPTS="
--no-mouse
--reverse
--height 75%
-1
--multi
--inline-info
--color='hl:148,hl+:154,pointer:032,marker:010,bg+:237,gutter:008'
--preview='([[ -d {} ]] && (tree -C {} | less)) || ([[ \$(file --mime {}) =~ binary ]] && echo {} is a binary file) || (bat --style=numbers --color=always {} || cat {}) 2> /dev/null | head -300' --preview-window='right:hidden:wrap'
--bind='?:toggle-preview,ctrl-d:half-page-down,ctrl-u:half-page-up,ctrl-a:select-all+accept,ctrl-y:execute-silent(echo {+} | pbcopy)'"

export FZF_DEFAULT_COMMAND="git ls-files --cached --others --exclude-standard | fd --type f --type l $FD_OPTIONS"
export FZF_CTRL_T_COMMAND="fd $FD_OPTIONS"
export FZF_ALT_C_COMMAND="fd --type d $FD_OPTIONS"

export BAT_THEME="TwoDark"


