import pymysql
import random
def create_sql_connecnt():
    db = pymysql.connect('192.168.0.109','root','123456','django_data')
    cursor = db.cursor()
    return db,cursor
 
def sql_ca(ca_words,db,cursor):
    mag_class_sql = 'insert into magazine_magclass(class_name) values("%s");'
    try:
        print(mag_class_sql % ca_words)
        cursor.execute(mag_class_sql % ca_words) #插入的分类SQL语句
        db.commit()
    except Exception as e:
        print('[E1]',e)
        db.rollback()
        return
    else:
        print('[+]杂志分类插入成功')
 
def sql_mag(mag_class_id, db,cursor,mag_info): 
    mag_info_sql = "insert into  magazine_maginfo(" + \
            "mag_class_id," + \
            "mag_name,mag_img," + \
            "mag_level,mag_part," + \
            "mag_make," + \
            "mag_id_out,mag_id_in,"+ \
            "mag_place, mag_code," + \
            "mag_birth, mag_loop," + \
            "mag_type, mag_money, mag_num)" + \
    ' values(%d, "%s", "%s", "%s", "%s", "%s", "%s", "%s", "%s", "%s", "%s", "%s", "%s", "%s", %d);'
 
    mag_name = mag_info['杂志名']
    mag_img = mag_info['杂志图片']
    mag_level = mag_info['杂志等级']
    mag_part = mag_info['主管单位']
    mag_make = mag_info['主办单位']
    mag_id_out = mag_info['国际刊号']
    mag_id_in = mag_info['国内刊号']
    mag_place = mag_info['出版地方']
    mag_code = mag_info['邮发代号']
    mag_birth = mag_info['创刊时间']
    mag_loop = mag_info['发行周期']
    mag_type = mag_info['业务类型']
    mag_money = random.randint(100,10000)
    try:
        cursor.execute( mag_info_sql % (
            mag_class_id,
            mag_name,mag_img,mag_level,
            mag_part,mag_make,mag_id_out,mag_id_in,
            mag_place,mag_code,mag_birth,mag_loop,
            mag_type,mag_money,0
            )
        )
        db.commit()
    except Exception as e:
        print('[E2]',e)
        db.rollback()
        return
    else:
        print('[+]杂志信息插入成功'