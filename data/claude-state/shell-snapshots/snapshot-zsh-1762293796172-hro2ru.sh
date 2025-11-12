# Snapshot file
# Unset all aliases to avoid conflicts with functions
unalias -a 2>/dev/null || true
# Functions
add-zle-hook-widget () {
	local -a hooktypes
	zstyle -a zle-hook types hooktypes
	local usage="Usage: $funcstack[1] hook widgetname\nValid hooks are:\n  $hooktypes" 
	local opt
	local -a autoopts
	integer del list help
	while getopts "dDhLUzk" opt
	do
		case $opt in
			(d) del=1  ;;
			(D) del=2  ;;
			(h) help=1  ;;
			(L) list=1  ;;
			([Uzk]) autoopts+=(-$opt)  ;;
			(*) return 1 ;;
		esac
	done
	shift $(( OPTIND - 1 ))
	1=${1#zle-} 
	if (( list ))
	then
		zstyle -L "zle-(${1:-${(@j:|:)hooktypes[@]}})" widgets
		return $?
	elif (( help || $# != 2 || ${hooktypes[(I)$1]} == 0 ))
	then
		print -u$(( 2 - help )) $usage
		return $(( 1 - help ))
	fi
	local -aU extant_hooks
	local hook="zle-$1" 
	local fn="$2" 
	if (( del ))
	then
		if zstyle -g extant_hooks "$hook" widgets
		then
			if (( del == 2 ))
			then
				set -A extant_hooks ${extant_hooks[@]:#(<->:|)${~fn}}
			else
				set -A extant_hooks ${extant_hooks[@]:#(<->:|)$fn}
			fi
			if (( ${#extant_hooks} ))
			then
				zstyle "$hook" widgets "${extant_hooks[@]}"
			else
				zstyle -d "$hook" widgets
			fi
		fi
	else
		if [[ "$fn" = "$hook" ]]
		then
			if (( ${+widgets[$fn]} ))
			then
				print -u2 "$funcstack[1]: Cannot hook $fn to itself"
				return 1
			fi
			autoload "${autoopts[@]}" -- "$fn"
			zle -N "$fn"
			return 0
		fi
		integer i=${#options[ksharrays]}-2 
		zstyle -g extant_hooks "$hook" widgets
		if [[ ${widgets[$hook]:-} != "user:azhw:$hook" ]]
		then
			if [[ -n ${widgets[$hook]:-} ]]
			then
				zle -A "$hook" "${widgets[$hook]}"
				extant_hooks=(0:"${widgets[$hook]}" "${extant_hooks[@]}") 
			fi
			zle -N "$hook" azhw:"$hook"
		fi
		if [[ -z ${(M)extant_hooks[@]:#(<->:|)$fn} ]]
		then
			i=${${(On@)${(@M)extant_hooks[@]#<->:}%:}[i]:-0}+1 
		else
			return 0
		fi
		extant_hooks+=("${i}:${fn}") 
		zstyle -- "$hook" widgets "${extant_hooks[@]}"
		if (( ! ${+widgets[$fn]} ))
		then
			autoload "${autoopts[@]}" -- "$fn"
			zle -N -- "$fn"
		fi
		if (( ! ${+widgets[$hook]} ))
		then
			zle -N "$hook" azhw:"$hook"
		fi
	fi
}
add-zsh-hook () {
	emulate -L zsh
	local -a hooktypes
	hooktypes=(chpwd precmd preexec periodic zshaddhistory zshexit zsh_directory_name) 
	local usage="Usage: add-zsh-hook hook function\nValid hooks are:\n  $hooktypes" 
	local opt
	local -a autoopts
	integer del list help
	while getopts "dDhLUzk" opt
	do
		case $opt in
			(d) del=1  ;;
			(D) del=2  ;;
			(h) help=1  ;;
			(L) list=1  ;;
			([Uzk]) autoopts+=(-$opt)  ;;
			(*) return 1 ;;
		esac
	done
	shift $(( OPTIND - 1 ))
	if (( list ))
	then
		typeset -mp "(${1:-${(@j:|:)hooktypes}})_functions"
		return $?
	elif (( help || $# != 2 || ${hooktypes[(I)$1]} == 0 ))
	then
		print -u$(( 2 - help )) $usage
		return $(( 1 - help ))
	fi
	local hook="${1}_functions" 
	local fn="$2" 
	if (( del ))
	then
		if (( ${(P)+hook} ))
		then
			if (( del == 2 ))
			then
				set -A $hook ${(P)hook:#${~fn}}
			else
				set -A $hook ${(P)hook:#$fn}
			fi
			if (( ! ${(P)#hook} ))
			then
				unset $hook
			fi
		fi
	else
		if (( ${(P)+hook} ))
		then
			if (( ${${(P)hook}[(I)$fn]} == 0 ))
			then
				typeset -ga $hook
				set -A $hook ${(P)hook} $fn
			fi
		else
			typeset -ga $hook
			set -A $hook $fn
		fi
		autoload $autoopts -- $fn
	fi
}
azhw:zle-history-line-set () {
	local -a hook_widgets
	local hook
	zstyle -a $WIDGET widgets hook_widgets
	for hook in "${(@)${(@on)hook_widgets[@]}#<->:}"
	do
		if [[ "$hook" = user:* ]]
		then
			zle "$hook" -f "nolast" -N -- "$@"
		else
			zle "$hook" -f "nolast" -Nw -- "$@"
		fi || return
	done
	return 0
}
azhw:zle-isearch-exit () {
	local -a hook_widgets
	local hook
	zstyle -a $WIDGET widgets hook_widgets
	for hook in "${(@)${(@on)hook_widgets[@]}#<->:}"
	do
		if [[ "$hook" = user:* ]]
		then
			zle "$hook" -f "nolast" -N -- "$@"
		else
			zle "$hook" -f "nolast" -Nw -- "$@"
		fi || return
	done
	return 0
}
azhw:zle-isearch-update () {
	local -a hook_widgets
	local hook
	zstyle -a $WIDGET widgets hook_widgets
	for hook in "${(@)${(@on)hook_widgets[@]}#<->:}"
	do
		if [[ "$hook" = user:* ]]
		then
			zle "$hook" -f "nolast" -N -- "$@"
		else
			zle "$hook" -f "nolast" -Nw -- "$@"
		fi || return
	done
	return 0
}
azhw:zle-keymap-select () {
	local -a hook_widgets
	local hook
	zstyle -a $WIDGET widgets hook_widgets
	for hook in "${(@)${(@on)hook_widgets[@]}#<->:}"
	do
		if [[ "$hook" = user:* ]]
		then
			zle "$hook" -f "nolast" -N -- "$@"
		else
			zle "$hook" -f "nolast" -Nw -- "$@"
		fi || return
	done
	return 0
}
azhw:zle-line-finish () {
	local -a hook_widgets
	local hook
	zstyle -a $WIDGET widgets hook_widgets
	for hook in "${(@)${(@on)hook_widgets[@]}#<->:}"
	do
		if [[ "$hook" = user:* ]]
		then
			zle "$hook" -f "nolast" -N -- "$@"
		else
			zle "$hook" -f "nolast" -Nw -- "$@"
		fi || return
	done
	return 0
}
azhw:zle-line-init () {
	local -a hook_widgets
	local hook
	zstyle -a $WIDGET widgets hook_widgets
	for hook in "${(@)${(@on)hook_widgets[@]}#<->:}"
	do
		if [[ "$hook" = user:* ]]
		then
			zle "$hook" -f "nolast" -N -- "$@"
		else
			zle "$hook" -f "nolast" -Nw -- "$@"
		fi || return
	done
	return 0
}
azhw:zle-line-pre-redraw () {
	local -a hook_widgets
	local hook
	zstyle -a $WIDGET widgets hook_widgets
	for hook in "${(@)${(@on)hook_widgets[@]}#<->:}"
	do
		if [[ "$hook" = user:* ]]
		then
			zle "$hook" -f "nolast" -N -- "$@"
		else
			zle "$hook" -f "nolast" -Nw -- "$@"
		fi || return
	done
	return 0
}
compaudit () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/functions/Completion
}
compdef () {
	local opt autol type func delete eval new i ret=0 cmd svc 
	local -a match mbegin mend
	emulate -L zsh
	setopt extendedglob
	if (( ! $# ))
	then
		print -u2 "$0: I need arguments"
		return 1
	fi
	while getopts "anpPkKde" opt
	do
		case "$opt" in
			(a) autol=yes  ;;
			(n) new=yes  ;;
			([pPkK]) if [[ -n "$type" ]]
				then
					print -u2 "$0: type already set to $type"
					return 1
				fi
				if [[ "$opt" = p ]]
				then
					type=pattern 
				elif [[ "$opt" = P ]]
				then
					type=postpattern 
				elif [[ "$opt" = K ]]
				then
					type=widgetkey 
				else
					type=key 
				fi ;;
			(d) delete=yes  ;;
			(e) eval=yes  ;;
		esac
	done
	shift OPTIND-1
	if (( ! $# ))
	then
		print -u2 "$0: I need arguments"
		return 1
	fi
	if [[ -z "$delete" ]]
	then
		if [[ -z "$eval" ]] && [[ "$1" = *\=* ]]
		then
			while (( $# ))
			do
				if [[ "$1" = *\=* ]]
				then
					cmd="${1%%\=*}" 
					svc="${1#*\=}" 
					func="$_comps[${_services[(r)$svc]:-$svc}]" 
					[[ -n ${_services[$svc]} ]] && svc=${_services[$svc]} 
					[[ -z "$func" ]] && func="${${_patcomps[(K)$svc][1]}:-${_postpatcomps[(K)$svc][1]}}" 
					if [[ -n "$func" ]]
					then
						_comps[$cmd]="$func" 
						_services[$cmd]="$svc" 
					else
						print -u2 "$0: unknown command or service: $svc"
						ret=1 
					fi
				else
					print -u2 "$0: invalid argument: $1"
					ret=1 
				fi
				shift
			done
			return ret
		fi
		func="$1" 
		[[ -n "$autol" ]] && autoload -rUz "$func"
		shift
		case "$type" in
			(widgetkey) while [[ -n $1 ]]
				do
					if [[ $# -lt 3 ]]
					then
						print -u2 "$0: compdef -K requires <widget> <comp-widget> <key>"
						return 1
					fi
					[[ $1 = _* ]] || 1="_$1" 
					[[ $2 = .* ]] || 2=".$2" 
					[[ $2 = .menu-select ]] && zmodload -i zsh/complist
					zle -C "$1" "$2" "$func"
					if [[ -n $new ]]
					then
						bindkey "$3" | IFS=$' \t' read -A opt
						[[ $opt[-1] = undefined-key ]] && bindkey "$3" "$1"
					else
						bindkey "$3" "$1"
					fi
					shift 3
				done ;;
			(key) if [[ $# -lt 2 ]]
				then
					print -u2 "$0: missing keys"
					return 1
				fi
				if [[ $1 = .* ]]
				then
					[[ $1 = .menu-select ]] && zmodload -i zsh/complist
					zle -C "$func" "$1" "$func"
				else
					[[ $1 = menu-select ]] && zmodload -i zsh/complist
					zle -C "$func" ".$1" "$func"
				fi
				shift
				for i
				do
					if [[ -n $new ]]
					then
						bindkey "$i" | IFS=$' \t' read -A opt
						[[ $opt[-1] = undefined-key ]] || continue
					fi
					bindkey "$i" "$func"
				done ;;
			(*) while (( $# ))
				do
					if [[ "$1" = -N ]]
					then
						type=normal 
					elif [[ "$1" = -p ]]
					then
						type=pattern 
					elif [[ "$1" = -P ]]
					then
						type=postpattern 
					else
						case "$type" in
							(pattern) if [[ $1 = (#b)(*)=(*) ]]
								then
									_patcomps[$match[1]]="=$match[2]=$func" 
								else
									_patcomps[$1]="$func" 
								fi ;;
							(postpattern) if [[ $1 = (#b)(*)=(*) ]]
								then
									_postpatcomps[$match[1]]="=$match[2]=$func" 
								else
									_postpatcomps[$1]="$func" 
								fi ;;
							(*) if [[ "$1" = *\=* ]]
								then
									cmd="${1%%\=*}" 
									svc=yes 
								else
									cmd="$1" 
									svc= 
								fi
								if [[ -z "$new" || -z "${_comps[$1]}" ]]
								then
									_comps[$cmd]="$func" 
									[[ -n "$svc" ]] && _services[$cmd]="${1#*\=}" 
								fi ;;
						esac
					fi
					shift
				done ;;
		esac
	else
		case "$type" in
			(pattern) unset "_patcomps[$^@]" ;;
			(postpattern) unset "_postpatcomps[$^@]" ;;
			(key) print -u2 "$0: cannot restore key bindings"
				return 1 ;;
			(*) unset "_comps[$^@]" ;;
		esac
	fi
}
compdump () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/functions/Completion
}
compinit () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/functions/Completion
}
compinstall () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/functions/Completion
}
prompt () {
	local -a prompt_opts theme_active
	zstyle -g theme_active :prompt-theme restore || {
		[[ -o promptbang ]] && prompt_opts+=(bang) 
		[[ -o promptcr ]] && prompt_opts+=(cr) 
		[[ -o promptpercent ]] && prompt_opts+=(percent) 
		[[ -o promptsp ]] && prompt_opts+=(sp) 
		[[ -o promptsubst ]] && prompt_opts+=(subst) 
		zstyle -e :prompt-theme restore "
        zstyle -d :prompt-theme restore
        prompt_default_setup
        ${PS1+PS1=${(q+)PS1}}
        ${PS2+PS2=${(q+)PS2}}
        ${PS3+PS3=${(q+)PS3}}
        ${PS4+PS4=${(q+)PS4}}
        ${RPS1+RPS1=${(q+)RPS1}}
        ${RPS2+RPS2=${(q+)RPS2}}
        ${RPROMPT+RPROMPT=${(q+)RPROMPT}}
        ${RPROMPT2+RPROMPT2=${(q+)RPROMPT2}}
        ${PSVAR+PSVAR=${(q+)PSVAR}}
        prompt_opts=( $prompt_opts[*] )
        reply=( yes )
    "
	}
	set_prompt "$@"
	(( ${#prompt_opts} )) && setopt noprompt{bang,cr,percent,sp,subst} "prompt${^prompt_opts[@]}"
	true
}
prompt_adam1_help () {
	cat <<'EOF'
This prompt is color-scheme-able.  You can invoke it thus:

  prompt adam1 [<color1> [<color2> [<color3>]]]

where the colors are for the user@host background, current working
directory, and current working directory if the prompt is split over
two lines respectively.  The default colors are blue, cyan and green.
This theme works best with a dark background.

Recommended fonts for this theme: nexus or vga or similar.  If you
don't have any of these, then specify the `plain' option to use 7-bit
replacements for the 8-bit characters.
EOF
}
prompt_adam1_precmd () {
	setopt localoptions noxtrace nowarncreateglobal
	local base_prompt_expanded_no_color base_prompt_etc
	local prompt_length space_left
	base_prompt_expanded_no_color=$(print -P "$base_prompt_no_color") 
	base_prompt_etc=$(print -P "$base_prompt%(4~|...|)%3~") 
	prompt_length=${#base_prompt_etc} 
	if [[ $prompt_length -lt 40 ]]
	then
		path_prompt="%B%F{$prompt_adam1_color2}%(4~|...|)%3~%F{white}" 
	else
		space_left=$(( $COLUMNS - $#base_prompt_expanded_no_color - 2 )) 
		path_prompt="%B%F{$prompt_adam1_color3}%${space_left}<...<%~$prompt_newline%F{white}" 
	fi
	PS1="$base_prompt$path_prompt %# $post_prompt" 
	PS2="$base_prompt$path_prompt %_> $post_prompt" 
	PS3="$base_prompt$path_prompt ?# $post_prompt" 
}
prompt_adam1_setup () {
	setopt localoptions nowarncreateglobal
	prompt_adam1_color1=${1:-'blue'} 
	prompt_adam1_color2=${2:-'cyan'} 
	prompt_adam1_color3=${3:-'green'} 
	base_prompt="%K{$prompt_adam1_color1}%n@%m%k " 
	post_prompt="%b%f%k" 
	setopt localoptions extendedglob
	base_prompt_no_color="${base_prompt//(%K{[^\\\}]#\}|%k)/}" 
	post_prompt_no_color="${post_prompt//(%K{[^\\\}]#\}|%k)/}" 
	add-zsh-hook precmd prompt_adam1_precmd
}
prompt_adam2_setup () {
	# undefined
	builtin autoload -XUz
}
prompt_bart_setup () {
	# undefined
	builtin autoload -XUz
}
prompt_bigfade_setup () {
	# undefined
	builtin autoload -XUz
}
prompt_cleanup () {
	local -a cleanup_hooks theme_active
	if ! zstyle -g cleanup_hooks :prompt-theme cleanup
	then
		if ! zstyle -g theme_active :prompt-theme restore
		then
			print -u2 "prompt_cleanup: no prompt theme active"
			return 1
		fi
		zstyle -e :prompt-theme cleanup 'zstyle -d :prompt-theme cleanup;' 'reply=(yes)'
		zstyle -g cleanup_hooks :prompt-theme cleanup
	fi
	cleanup_hooks+=(';' "$@") 
	zstyle -e :prompt-theme cleanup "${cleanup_hooks[@]}"
}
prompt_clint_setup () {
	# undefined
	builtin autoload -XUz
}
prompt_default_setup () {
	# undefined
	builtin autoload -XUz
}
prompt_elite2_setup () {
	# undefined
	builtin autoload -XUz
}
prompt_elite_setup () {
	# undefined
	builtin autoload -XUz
}
prompt_fade_setup () {
	# undefined
	builtin autoload -XUz
}
prompt_fire_setup () {
	# undefined
	builtin autoload -XUz
}
prompt_off_setup () {
	# undefined
	builtin autoload -XUz
}
prompt_oliver_setup () {
	# undefined
	builtin autoload -XUz
}
prompt_preview_safely () {
	emulate -L zsh
	print -P "%b%f%k"
	if [[ -z "$prompt_themes[(r)$1]" ]]
	then
		print "Unknown theme: $1"
		return
	fi
	(
		zstyle -t :prompt-theme cleanup
		typeset +f prompt_${1}_preview >&/dev/null || prompt_${1}_setup
		if typeset +f prompt_${1}_preview >&/dev/null
		then
			prompt_${1}_preview "$@[2,-1]"
		else
			prompt_preview_theme "$@"
		fi
	)
}
prompt_preview_theme () {
	emulate -L zsh
	local -a prompt_opts
	print -n "$1 theme"
	(( $#* > 1 )) && print -n " with parameters \`$*[2,-1]'"
	print ":"
	zstyle -t :prompt-theme cleanup
	prompt_${1}_setup "$@[2,-1]"
	(( ${#prompt_opts} )) && setopt noprompt{bang,cr,percent,sp,subst} "prompt${^prompt_opts[@]}"
	[[ -n ${chpwd_functions[(r)prompt_${1}_chpwd]} ]] && prompt_${1}_chpwd
	[[ -n ${precmd_functions[(r)prompt_${1}_precmd]} ]] && prompt_${1}_precmd
	[[ -o promptcr ]] && print -n $'\r'
	:
	print -P -- "${PS1}command arg1 arg2 ... argn"
	[[ -n ${preexec_functions[(r)prompt_${1}_preexec]} ]] && prompt_${1}_preexec
}
prompt_pws_setup () {
	# undefined
	builtin autoload -XUz
}
prompt_redhat_setup () {
	# undefined
	builtin autoload -XUz
}
prompt_restore_setup () {
	# undefined
	builtin autoload -XUz
}
prompt_suse_setup () {
	# undefined
	builtin autoload -XUz
}
prompt_walters_setup () {
	# undefined
	builtin autoload -XUz
}
prompt_zefram_setup () {
	# undefined
	builtin autoload -XUz
}
promptinit () {
	emulate -L zsh
	setopt extendedglob
	autoload -Uz add-zsh-hook add-zle-hook-widget
	local ppath='' name theme 
	local -a match mbegin mend
	for theme in $^fpath/prompt_*_setup(N)
	do
		if [[ $theme == */prompt_(#b)(*)_setup ]]
		then
			name="$match[1]" 
			if [[ -r "$theme" ]]
			then
				prompt_themes=($prompt_themes $name) 
				autoload -Uz prompt_${name}_setup
			else
				print "Couldn't read file $theme containing theme $name."
			fi
		else
			print "Eh?  Mismatch between glob patterns in promptinit."
		fi
	done
	prompt_newline=$'\n%{\r%}' 
}
set_prompt () {
	emulate -L zsh
	local opt preview theme usage old_theme
	usage='Usage: prompt <options>
Options:
    -c              Show currently selected theme and parameters
    -l              List currently available prompt themes
    -p [<themes>]   Preview given themes (defaults to all except current theme)
    -h [<theme>]    Display help (for given theme)
    -s <theme>      Set and save theme
    <theme>         Switch to new theme immediately (changes not saved)

Use prompt -h <theme> for help on specific themes.' 
	getopts "chlps:" opt
	case "$opt" in
		(c) if [[ -n $prompt_theme ]]
			then
				print -n "Current prompt theme"
				(( $#prompt_theme > 1 )) && print -n " with parameters"
				print " is:\n  $prompt_theme"
			else
				print "Current prompt is not a theme."
			fi
			return ;;
		(h) if [[ -n "$2" && -n $prompt_themes[(r)$2] ]]
			then
				(
					zstyle -t :prompt-theme cleanup
					typeset +f prompt_$2_help > /dev/null || prompt_$2_setup
					if typeset +f prompt_$2_help > /dev/null
					then
						print "Help for $2 theme:\n"
						prompt_$2_help
					else
						print "No help available for $2 theme."
					fi
					print "\nType \`prompt -p $2' to preview the theme, \`prompt $2'"
					print "to try it out, and \`prompt -s $2' to use it in future sessions."
				)
			else
				print "$usage"
			fi ;;
		(l) print Currently available prompt themes:
			print $prompt_themes
			return ;;
		(p) preview=(${prompt_themes:#$prompt_theme}) 
			(( $#* > 1 )) && preview=("$@[2,-1]") 
			for theme in $preview
			do
				prompt_preview_safely "$=theme"
			done
			print -P "%b%f%k" ;;
		(s) print "Set and save not yet implemented.  Please ensure your ~/.zshrc"
			print "contains something similar to the following:\n"
			print "  autoload -Uz promptinit"
			print "  promptinit"
			print "  prompt $*[2,-1]"
			shift ;&
		(*) if [[ "$1" == 'random' ]]
			then
				local random_themes
				if (( $#* == 1 ))
				then
					random_themes=($prompt_themes) 
				else
					random_themes=("$@[2,-1]") 
				fi
				local i=$(( ( $RANDOM % $#random_themes ) + 1 )) 
				argv=("${=random_themes[$i]}") 
			fi
			if [[ -z "$1" || -z $prompt_themes[(r)$1] ]]
			then
				print "$usage"
				return
			fi
			local hook
			for hook in chpwd precmd preexec periodic zshaddhistory zshexit zsh_directory_name
			do
				add-zsh-hook -D "$hook" "prompt_*_$hook"
			done
			for hook in isearch-exit isearch-update line-pre-redraw line-init line-finish history-line-set keymap-select
			do
				add-zle-hook-widget -D "$hook" "prompt_*_$hook"
			done
			typeset -ga zle_highlight=(${zle_highlight:#default:*}) 
			(( ${#zle_highlight} )) || unset zle_highlight
			zstyle -t :prompt-theme cleanup
			prompt_$1_setup "$@[2,-1]" && prompt_theme=("$@")  ;;
	esac
}
# Shell Options
setopt nohashdirs
setopt histignorealldups
setopt login
setopt sharehistory
# Aliases
alias -- run-help=man
alias -- which-command=whence
# Check for rg availability
if ! command -v rg >/dev/null 2>&1; then
  alias rg='/home/jamestroutman/.vscode-server/extensions/anthropic.claude-code-2.0.30-linux-x64/resources/native-binary/claude --ripgrep'
fi
export PATH='/home/jamestroutman/.vscode-server/bin/7d842fb85a0275a4a8e4d7e040d2625abbf7f084/bin/remote-cli:/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/usr/lib/wsl/lib:/mnt/c/Python313/Scripts/:/mnt/c/Python313/:/mnt/c/Windows/system32:/mnt/c/Windows:/mnt/c/Windows/System32/Wbem:/mnt/c/Windows/System32/WindowsPowerShell/v1.0/:/mnt/c/Windows/System32/OpenSSH/:/mnt/c/ProgramData/chocolatey/bin:/mnt/c/Program Files/dotnet/:/mnt/c/Program Files/ShareFile/ShareFile for Windows/:/Docker/host/bin:/mnt/c/Program Files/nodejs/:/mnt/c/Users/JamesTroutman/.cargo/bin:/mnt/c/Users/JamesTroutman/scoop/shims:/mnt/c/Users/JamesTroutman/AppData/Local/Microsoft/WindowsApps:/mnt/c/Users/JamesTroutman/AppData/Local/Programs/Microsoft VS Code/bin:/mnt/c/Users/JamesTroutman/AppData/Local/Programs/Git/cmd:/mnt/c/Users/JamesTroutman/AppData/Local/Programs/Git/mingw64/bin:/mnt/c/Users/JamesTroutman/AppData/Local/Programs/Git/usr/bin:/mnt/c/Users/JamesTroutman/AppData/Roaming/npm:/mnt/c/Users/JamesTroutman/AppData/Local/Microsoft/WinGet/Packages/GitKraken.cli_Microsoft.Winget.Source_8wekyb3d8bbwe:/home/jamestroutman/.local/bin:/home/jamestroutman/.local/bin'
