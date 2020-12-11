### macOS安装python3.6.x
```
brew install python3
```
或 下载安装器
```
https://www.python.org/downloads/mac-osx/
```

### sublime text3安装package control
1. Tools -> Build System -> New Build System (保存为新文件Python36.sublime-build)
```
{
"cmd": ["/Library/Frameworks/Python.framework/Versions/3.6/bin/python3", "-u", "$file"],
"file_regex": "^[ ]*File \"(...*?)\", line ([0-9]*)",
"env": {"PYTHONIOENCODING": "utf8"}, 
"selector": "source.python"
}
```

2. Tools -> Build System ->Python36
> https://packagecontrol.io/installation