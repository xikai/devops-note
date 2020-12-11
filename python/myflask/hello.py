from flask import Flask, escape
from flask import render_template, request, make_response
from flask import session, redirect, url_for
app = Flask(__name__)


# 路由
@app.route('/hello')
def hello_world():
    return 'Hello, World World!!!!'

@app.route('/user/<username>')
def show_user_profile(username):
    # show the user profile for that user
    return 'User %s' % escape(username)

@app.route('/post/<int:post_id>')
def show_post(post_id):
    # show the post with the given id, the id is an integer
    return 'Post %d' % post_id

@app.route('/path/<path:subpath>')
def show_subpath(subpath):
    # show the subpath after /path/
    return 'Subpath %s' % escape(subpath)

@app.route('/')
# def index():
#     return render_template('hello.html')

# 渲染模板文件render_template
def index():
    '''
        看我能注释不
    '''
    # 往模板中传入的数据
    my_str = 'Hello Word'
    my_int = 10
    my_array = [3, 4, 2, 1, 7, 9]
    my_dict = {
        'name': 'xiaoming',
        'age': 18
    }
    return render_template('hello.html',
                           my_str=my_str,
                           my_int=my_int,
                           my_array=my_array,
                           my_dict=my_dict
                           )

# request form表单
@app.route('/student')
def student():
   return render_template('student.html')

@app.route('/result',methods = ['POST', 'GET'])
def result():
   if request.method == 'POST':
      result = request.form
      return render_template("result.html",result = result)


# cookie make_response 
@app.route("/set_cookies")
def set_cookie():
    resp = make_response("success")
    resp.set_cookie("w3cshool", "w3cshool",max_age=3600)
    return resp

@app.route("/get_cookies")
def get_cookie():
    cookie_1 = request.cookies.get("w3cshool")  # 获取名字为Itcast_1对应cookie的值
    return cookie_1

@app.route("/delete_cookies")
def delete_cookie():
    resp = make_response("del success")
    resp.delete_cookie("w3cshool")
    return resp


# session会话
app.secret_key = 'fkdjsafjdkfdlkjfadskjfadskljdsfklj'
@app.route('/admin')
def admin():
    if 'username' in session:
        return 'Logged in as %s' % escape(session['username']) + '<br>' + \
            "<b><a href = '/logout'>Click Logout</a></b>"
    return 'You are not logged in' + '<br>' + \
        "<b><a href = '/login'>Click Login</a></b>"

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        session['username'] = request.form['username']
        return redirect(url_for('admin'))
    return '''
        <form method="post">
            <p><input type=text name=username>
            <p><input type=submit value=Login>
        </form>
    '''

@app.route('/logout')
def logout():
    # remove the username from the session if it's there
    session.pop('username', None)
    return redirect(url_for('admin'))




if __name__ == '__main__':
    #app.run()
    app.run(debug=True)