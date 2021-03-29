* 配置Terminal终端通过ss上网
>vim /etc/profile
```
alias proxy='export all_proxy=socks5://127.0.0.1:7070'
alias unproxy='unset all_proxy'
```

* iterm2反空闲
```
ssh -o ServerAliveInterval=60 root@202.10.76.16
```
* vim语法高亮
> vim .vimrc
```
syntax on
colorscheme peachpuff
```


* mac bash terminal提示符修改
>vim ~/.bash_profile
```
parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}
export PS1="\[\033[32m\]\w\[\033[33m\]\$(parse_git_branch)\[\033[00m\]\n \[\e[36m\]\A\[\e[m\] $ "
export CLICOLOR=1
export LSCOLORS=Exfxcxdxbxegedabagacad
```

* 安装homebrew包管理器
>https://brew.sh/index_zh-cn



### mac zsh terminal提示符修改,安装oh-my-zsh (https://ohmyz.sh)
* 修改simple主题
> vim .oh-my-zsh/themes/simple.zsh-theme
```
# PROMPT='%(!.%{$fg[red]%}.%{$fg[green]%})%~%{$fg_bold[blue]%}$(git_prompt_info)%{$reset_color%} '
PROMPT='%(!.%{$fg[red]%}.%{$fg[green]%})%~ ${FG[133]}$(git_prompt_info)
%{$fg_bold[blue]%}%T %{$reset_color%}$ '

ZSH_THEME_GIT_PROMPT_PREFIX="("
ZSH_THEME_GIT_PROMPT_SUFFIX=")"
ZSH_THEME_GIT_PROMPT_DIRTY=" ✗"
ZSH_THEME_GIT_PROMPT_CLEAN=" ✔"
```
* zsh启用simple主题
>vim ~/.zshrc
```
ZSH_THEME="simple"
```

* 微信多开
```
open -n /Applications/WeChat.app/Contents/MacOS/WeChat
```