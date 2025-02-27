# 配置Terminal终端通过ss上网
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

# [iterm2](https://iterm2.com/index.html)
* [github dark](https://raw.githubusercontent.com/mbadolato/iTerm2-Color-Schemes/master/schemes/GitHub%20Dark.itermcolors)
* 反空闲
```
ssh -o ServerAliveInterval=60 root@202.10.76.16
```
# vim语法高亮
> vim .vimrc
```
syntax on
colorscheme peachpuff
```

# [iterm2 lrzsz](https://github.com/RobberPhex/iTerm2-zmodem)
```
brew install lrzsz
```
* 下载iterm2-zmodem，在iTerm2中使用Zmodem传输文件
```
curl -L https://raw.githubusercontent.com/robberphex/iTerm2-zmodem/refs/heads/main/iterm2-recv-zmodem.sh -o /usr/local/bin/iterm2-recv-zmodem.sh
curl -L https://raw.githubusercontent.com/robberphex/iTerm2-zmodem/refs/heads/main/iterm2-send-zmodem.sh -o /usr/local/bin/iterm2-send-zmodem.sh
chmod 755 /usr/local/bin/iterm2-*
```
* [iTerm2 配置添加rz sz 功能](https://iterm2.com/documentation-triggers.html)
>点击 iTerm2 的设置界面 settings-> Profiles -> Default -> Advanced -> Triggers 的 Edit 按钮

Regular Expression | Action | Parameters | Instant
---  | --- | --- | ---
rz waiting to receive.\*\*B0100	| Run Silent Coprocess	| /usr/local/bin/iterm2-send-zmodem.sh	| checked
\*\*B00000000000000	| Run Silent Coprocess	| /usr/local/bin/iterm2-recv-zmodem.sh	| checked


# [brew包管理器](https://brew.sh)

# 微信多开
```
open -n /Applications/WeChat.app/Contents/MacOS/WeChat
```

# sshkey ppk转pem
```
brew upgrade
brew install putty
puttygen test.ppk -O private-openssh -o test.pem
```

# route
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

# bash terminal提示符修改
>vim ~/.bash_profile
```
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}
export PS1="\[\033[32m\]\w\[\033[33m\]\$(parse_git_branch)\[\033[00m\]\n \[\e[36m\]\A\[\e[m\] $ "
export CLICOLOR=1
export LSCOLORS=Exfxcxdxbxegedabagacad
```

# zsh terminal提示符修改
>vim ~/.zshrc
* https://zsh.sourceforge.io/Doc/Release/Prompt-Expansion.html
```sh
zsh默认提示信息配置是 %n@%m %1~ %#，其中：

%n 是当前用户名
%m 是当前本地主机名
%1~ 是当前目录，不过会自动将用户目录替换为~
%# 是提示符，普通用户默认提示符是%，当具有超级用户权限时会显示#

%F{color}: 设置前景色为指定的颜色。其中，color 可以是预定义的颜色名称（如 black、red、green、yellow 等），或者是 ANSI 色彩代码（如 #RRGGBB）。
%f: 重置前景色为默认值。
%B: 设置文本为粗体。
%b: 取消粗体设置。
%U: 设置文本下划线。
%u: 取消下划线设置。
```
```sh
parse_k8s_current_context() {
    kubectl config current-context
}

parse_git_branch() {
    git branch 2> /dev/null | sed -n -e 's/^\* \(.*\)/(\1) /p'
}

export PS1="%F{green}%~ %F{magenta}$(parse_git_branch) %F{yellow}=> $(parse_k8s_current_context)
%F{blue}%T %f%b%# "
export CLICOLOR=1
```

# [oh-my-zsh](https://ohmyz.sh)
* 修改simple主题
> vim .oh-my-zsh/themes/k8s.zsh-theme
```
PROMPT='%(!.%{$fg[red]%}.%{$fg[green]%})%~ $(git_prompt_info) %{$fg[yellow]%}=> $(parse_k8s_current_context)
%{$fg_bold[blue]%}%T %{$reset_color%}$ '

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[magenta]%}("
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$fg_bold[magenta]%})"
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg[red]%}✗"
ZSH_THEME_GIT_PROMPT_CLEAN=" %{$fg[green]%}✔"
```
* zsh启用simple主题,提示符增加k8s context
>vim ~/.zshrc
```
ZSH_THEME="k8s"

parse_k8s_current_context() {
    kubectl config current-context
}

export CLUSTER_PATH="$HOME/Desktop/git-ops/ops-kubeconfig/clusters"

# AWS_PROFILE
alias awstest='export AWS_PROFILE=test'
alias awsprod='export AWS_PROFILE=prod'

# k8s ENV alias
alias k8sdev='awstest && export KUBECONFIG=$CLUSTER_PATH/eks/newdev/kubeconfig.yaml'
alias k8stest='awstest && export KUBECONFIG=$CLUSTER_PATH/eks/newtest01/kubeconfig.yaml'
alias k8stesta='awstest && export KUBECONFIG=$CLUSTER_PATH/eks/testa/kubeconfig.yaml'
alias k8stest2='awstest && export KUBECONFIG=$CLUSTER_PATH/eks/newtest02/kubeconfig.yaml'
alias k8spre='awsprod && export KUBECONFIG=$CLUSTER_PATH/eks/newpre/kubeconfig.yaml'
alias k8sprod='awsprod && export KUBECONFIG=$CLUSTER_PATH/eks/newproduct/kubeconfig.yaml'
alias unk8s='unset KUBECONFIG'
alias k='kubectl'
```

# termux
* 启动sshd服务
```
pkg install openssh
sshd
ssh localhost -p 8022  # 验证ssh

ifconfig #查看IP
whoami #查看用户
passwd #设置密码
```
* 客户端ssh连接（同一局域网）
```
ssh -p 8022 u0_a308@192.168.0.174
```

# vscode markdown文件默认以预览模式打开
1. 打开命令行模式（command+shift+p）
2. 输入：Open User Settings(JSON)，打开用户settings.json文件
3. 在 settings.json 文件中，添加以下配置项：
```
{
    "markdown.preview.openMarkdownLinks": "inPreview",
    "workbench.editorAssociations": {
      "*.md": "vscode.markdown.preview.editor"
    },
    "markdown.preview.fontSize": 12
}
```

# [chflags修改文件目录属性](https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man2/chflags.2.html)
```
hidden：将文件或目录标记为隐藏，使其在图形界面的 Finder 中不可见。
nohidden：取消文件或目录的隐藏标记。
uchg：防止文件被修改、重命名或删除，只有超级用户或文件的拥有者才能更改标志。
nouchg：取消用户更改禁止标志。
schg：防止文件被修改、重命名或删除，只有超级用户才能更改标志。
noschg：取消系统更改禁止标志。
```
```
# man chflags
sudo chflags -hv noschg /Applications/CorpLink.app
sudo /usr/bin/chflags -R noschg /usr/local/corplink
sudo rm -rf /Applications/CorpLink.app
sudo rm -rf /usr/local/corplink
```