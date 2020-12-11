git config --global user.name "Your Name"
git config --global user.email "email@example.com"
git config core.filemode false        #忽略文件权限


#查看远程仓库地址
git remote -v

#增加删除远程仓库地址
git remote rm origin
git remote add origin git@gitlab.ve.cn:xikai/test.git
git remote add originxik git@github_xik:xikai/test.git


#修改远程仓库地址
git remote set-url origin git@gitlab.ve.cn:xikai/test.git


#身份认证
1,生成本地主机id_rsa.pub公钥，将内容添加到gitlab的SSH keys
2,使用帐户验证 在gitlab创建帐户，添加用户到project member


#直接从远程库克隆
git clone git@gitlab.ve.cn:xikai/test.git
git clone http://gitlab.ve.cn/xikai/test.git


#提交文件到git版本库
git add file                 #把文件修改添加到暂存区
git rm                       #从版本库删除文件
git commit -m "xxxxx"        #把暂存区的所有内容提交到当前分支
git status

git log                        #显示版本日志
git reflog                    #列出所有操作记录

git checkout -- readme.txt    #将工作区指定文件回到最近一次git commit或git add时的状态
git reset HEAD readme.txt     #将暂存区指定文件重新撤回工作区

#工作区临时回退到指定commit版本(pull后回到最新版本)
git reset --hard HEAD^        #回退到上一个版本
git reset --hard HEAD~100     #回退到上100个版本
git reset --hard 3628164      #回到指定commit ID的版本(commit ID不用写全)

#储藏
git stash                    #把当前工作现场"储藏"起来，等以后恢复现场后继续工作(你当前的工作还没有完成提交,当前又必须先去修复bug时,需要将当前工作区“储藏”起来，保持工作区干净)
git stash pop                #恢复之前"储藏"的工作现场，同时把stash内容也删除
git stash list                #查看stash内容


#分支管理
一个成功的git分支方案： 
http://blog.csdn.net/dbzhang800/article/details/6798724

git branch -a                            #列出所有本地分支及远程分支
git checkout -b develop                 #创建并切换develop分支
git checkout develop                    #切换分支

git branch -d myfeature                   #删除develop本地分支(git branch -D myfeature 强行删除没有被合并的分支)

#删除远程库分支
git branch -r -d origin/develop            #删除本地对应的remotes/origin/develop
git push origin  :develop                #将本地空的分支推送到远程指定分支,冒号前面空格不能少

git checkout -b develop origin/develop    #创建远程develop分支到本地
git branch --set-upstream branch-name origin/branch-name        #建立本地分支和远程分支的关联


#合并分支
git merge develop
git merge --no-ff -m "commit message" develop            #合并develop分支到当前分支(develop分支文件的内容会覆盖当前的内容)  

注：合并分支默认会使用Fast forward "快进模式"，合并功能分支所有的commit信息，当被合并的功能分支被删除时，会丢失分支信息; --no-ff禁用快进模式，Git就会在merge时生成一个新的commit

# 合并指定commit（ 合并某个分支某个commit 到当前分支）
假设分支A和分支B, 我们想把A上的某个commit 点合并到B分支上
git checkout A (切换到A分支）
git log (查看所有commit 点，找到需要合并到B上的CommitId 复制commitId)
git checkout B （切回到B分支）
git cherry-pick [commitid] (上面复制的A分支的commitId)



#推送拉取
git remote -v                #查看远程git服务端地址

git push -u origin master    #推送本地当前指定分支到远程服务端 -u第一次推送用于关联本地master分支与远程master分支
git push -u origin develop
git pull origin master        #从远程git服务器拉取指定分支数据到本地当前分支
git pull origin develop

git push --tags                    #推送所有分支及tag
git pull --tags                    #拉取所有分支tag

git fetch origin master            #将远程master分支在本地更新为一个名为origin/master的本地分支

#pull所有分支到本地
  git branch -r | grep -v '\->' | while read remote; do git branch --track "${remote#origin/}" "$remote"; done
  git fetch --all
  git pull --all


注： git pull = git fetch + git merge

#标签管理
git tag                                     #列出所有tag
git tag -a v1.0 -m "v1.0"                   #为当前分支打标签
git tag v0.9 6224937                        #为指定版本打标签
git push origin --tags                      #推送tags
git pull origin --tags                      #更新当前分支和tags
git checkout v1.0                           #检出指定tag
git show v0.1                               #查看tag信息

git tag -d v0.1                                #删除本地标签
git push origin :refs/tags/v0.1                #删除远程标签(必须先删除本地标签再push origin)


#删除文件历史缓存记录
git filter-branch --force --index-filter 'git rm --cached --ignore-unmatch 文件名' --prune-empty --tag-name-filter cat -- --all
git push origin master --force
rm -rf .git/refs/original/
git reflog expire --expire=now --all
git gc --prune=now
git gc --aggressive --prune=now


#忽略特殊文件
有些时候，你必须把某些文件放到Git工作目录中，但又不能提交它们，比如保存了数据库密码的配置文件等等，每次git status都会显示“Untracked files ...”，有强迫症的童鞋心里肯定不爽
解决方法：在Git工作区的根目录下创建一个特殊的.gitignore文件，然后把要忽略的文件名填进去，提交.gitignore文件到版本库，Git就会自动忽略.gitignore中的文件

#curl下载git项目指定文件
https://docs.gitlab.com/ee/api/repository_files.html
curl --request GET --header 'PRIVATE-TOKEN: <your_access_token>' 'https://gitlab.example.com/api/v4/projects/13083/repository/files/app%2Fmodels%2Fkey%2Erb/raw?ref=master'


#在一台电脑上使用两个Github账号
http://blog.lessfun.com/blog/2014/06/11/two-github-account-in-one-client/

vim .ssh/config
--------------------------------
Host github.com
  HostName github.com
  IdentityFile ~/.ssh/id_rsa

Host github_dd01
  HostName github.com
  IdentityFile ~/.ssh/id_rsa_dd01
--------------------------------

git clone git@github_dd01:hk01-digital/ops-terraform.git

1.取消global
git config --global --unset user.name
git config --global --unset user.email

2.设置每个项目repo的自己的user.email
git config  user.email "xxxx@xx.com"
git config  user.name "xxxx"