* 配置Terminal终端通过ss上网
>vim /etc/profile
```
alias proxy='export all_proxy=socks5://127.0.0.1:7070'
alias unproxy='unset all_proxy'
```
* 通过SOCKS代理服务器 启动Chrome浏览器
```
"/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome" \
    --proxy-server="socks5://localhost:${PORT}" \
    --user-data-dir=/tmp/${HOSTNAME}
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

* sshkey ppk转pem
```
brew upgrade
brew install putty
puttygen test.ppk -O private-openssh -o test.pem
```

* 添加路由
```
# route add -net 目标网段/子网长度 下一跳IP
sudo route add -net 10.128.0.0/20 192.168.42.1
```
* 删除路由
```
sudo route delete -net 10.128.0.0/20
```
* 查看路由表
```
netstat -nr
```

# [iterm2 color](https://iterm2colorschemes.com/)
* [github dark](https://raw.githubusercontent.com/mbadolato/iTerm2-Color-Schemes/master/schemes/GitHub%20Dark.itermcolors)