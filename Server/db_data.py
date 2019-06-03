import datetime
from typing import Dict

import pymongo
from mongoengine import Document, StringField, DateField, connect, EmailField, EmbeddedDocument, DateTimeField, \
    ListField, EmbeddedDocumentField, ReferenceField, SortedListField, NotUniqueError, ValidationError
from pymongo.errors import DuplicateKeyError

DATABASE_NAME = 'user_table'
connect('user_table',alias = 'default')


def set_up_db():
    return connect(DATABASE_NAME)


class User(Document):
    username = StringField(max_length=50, required=True, unique=True)
    email = EmailField(required=True, unique=True)
    birth_date = DateField(max_length=50, default="1970-1-1")
    password = StringField(max_length=50, required=True)

    last_record_time = DateField(max_length=50)

    @staticmethod
    def insert_user(email, username, birth_date, password):
        u = User(email=email, username=username, birth_date=birth_date, password=password).save()
        return u

    @staticmethod
    def delete_user(username):
        users = User.objects(username=username)
        for user in users:
            user.delete()

    @staticmethod
    def update_user(username, kwargs: Dict):
        """update user with specifying username"""
        users = User.objects(username=username)
        for user in users:
            for k in kwargs:
                if k in user:
                    print(f"updating fields: {k}")
                    user[k] = kwargs[k]
            user.save()

    @staticmethod
    def query_user_by_name(username):
        user = User.objects(username=username).first()
        return user

    @staticmethod
    def query_users_by_id(user_id):
        user = User.objects(id=user_id).first()
        return user

    @property
    def user_id(self):
        return str(self.id)

    def __str__(self):
        return f"<{self.__class__.__name__}, id:{self.user_id} email: {self.email}, username: {self.username}, birth_date: {self.birth_date}, password: {self.password}>"


class Record(EmbeddedDocument):
    timestamp = DateTimeField(default=datetime.datetime.now)
    msg = StringField(required=True)

    def __str__(self):
        return f"<Record>,  msg: {self.msg}, timestamp: {self.timestamp}"


class History(Document):
    user = ReferenceField(User, unique=True)
    records = SortedListField(EmbeddedDocumentField(Record), ordering="timestamp", reverse=True)

    @staticmethod
    def get_history_records(user, limit=5):
        """get_history"""
        history = History.objects(user=user).first()
        if history:
            return history.records[:limit]
        else:
            return []

    @staticmethod
    def insert_history_record(user, msg):
        """insert history to a user"""
        record = Record(msg=msg)
        history = History.objects(user=user).first()
        if not history:
            history = History(user=user, records=[])
        history.records.append(record)
        history.save()
        return record


def drop_database(conn, table_name):
    """delete table"""
    conn.drop_database(table_name)


def check_require(require, data):
    for u in require:
        if not data.get(u):
            return u
    return False


class UserManager:
    def __init__(self, username, password, login_required=True):
        self.login_required = login_required
        self.password = password
        self.username = username
        self.error = None
        self.user = None

    def change_username(self, field_new_value):
        return self.change("username", field_new_value, True)

    def change_email(self, field_new_value):
        return self.change("email", field_new_value, True)

    def change_password(self, field_new_value):
        return self.change("password", field_new_value, False)

    def change(self, field_name, field_new_value, unique):
        if self.validate():
            if self.user[field_name] == field_new_value:
                self.error = f'new_{field_name} is the same as the old one'
            elif unique and User.objects(**{field_name: field_new_value}):
                self.error = f'Your {field_name} has been used'
            else:
                self.user[field_name] = field_new_value
                try:
                    self.user.save()
                except ValidationError as e:
                    self.login()
                    print(self.user)
                    self.error = str(e)
                    print(self.error)
                    if field_name in self.error:
                        self.error = f"Invalid {field_name} format"
        return self.user, self.error

    def validate(self):
        if self.login_required:
            return self.login()
        else:
            return self.get_user()

    def get_user(self):
        if not self.username:
            return None, f"Username is missing"
        users = User.objects(username=self.username)
        if len(users) == 0:
            self.error = f"Username is not exist"
            return False
        else:
            self.user = users[0]
            return True

    def login(self):
        self.user, self.error = authentication(self.username, self.password)
        if self.user:
            return True
        else:
            return False


def authentication(username, password):
    if not username:
        return None, f"Username is missing"
    if not password:
        return None, f"Password is missing"
    users = User.objects(username=username)
    error = None
    user = None
    if len(users) == 0:
        error = f"Username is not exist"
    elif users[0].password != password:
        error = f"Password Incorrect"
    else:
        user = users[0]
    return user, error


def user_register(username, email, password, password_second):
    error = None
    user = None
    if not username:
        error = f"username missing"
    elif not email:
        error = f"email missing"
    elif not password:
        error = f"password missing"
    elif not password_second:
        error = f"second password missing"
    elif password != password_second:
        error = f"two passwords are not the same"
    else:
        try:
            user = User.insert_user(email=email, username=username, birth_date="1970-1-1", password=password)
        except NotUniqueError as e:
            error = str(e)
            if "email" in error:
                error = f"E-mail have alredy been taken"
            elif "username" in error:
                error = f"Username have alredy been taken"
        except ValidationError as e:
            error = str(e)
            if "email" in error:
                error = f"Invalid E-mail address"
    return user, error


def user_response_dict(user, error):
    # succuss
    if user and not error:
        return {"status": 1, "content": {"username": user.username, "email": user.email}}
    # fail without user user_inof
    else:
        return {"status": 0, "content": {"error": error}}


def populate_users():
    User.insert_user(email='ross@example.com', username='ross', birth_date="2019-1-1", password="123")
    User.insert_user(email='nancy@example.com', username='nancy', birth_date="2019-1-1", password="123")
    User.insert_user(email='tom@example.com', username='tom', birth_date="2019-1-1", password="123")
    User.insert_user(email='raven@example.com', username='raven', birth_date="2019-1-1", password="123")
    User.insert_user(email='thomas@example.com', username='thomas', birth_date="2019-1-1", password="123")
    User.insert_user(email='lis@example.com', username='lis', birth_date="2019-1-1", password="123")
    alex = User.insert_user(email='alex@example.com', username='alex', birth_date="2019-1-1", password="123")
    User.insert_user(email='john@example.com', username='john', birth_date="2019-1-1", password="123")
    History.insert_history_record(alex, "take one")
    History.insert_history_record(alex, "take two")
    History.insert_history_record(alex, "take three")
    History.insert_history_record(alex, "take four")
    History.insert_history_record(alex, "take five")
    History.insert_history_record(alex, "take six")
    History.insert_history_record(alex, "take seven")



def test_functions():
    print("----------------------------------------------------------------------------------------------------")
    print("testing db begin")
    for u in User.objects:
        print(u)
    User.update_user('john', {"time": 1, "username": "alison"})
    User.delete_user("john")
    alison = User.query_user_by_name("alison")
    print(alison)

    alex = User.query_user_by_name("alex")

    print("getting alex five history")
    for record in History.get_history_records(alex, 5):
        print(record)

    for record in History.get_history_records(alison, 5):
        print(record)
    print("testing db end")
    print("----------------------------------------------------------------------------------------------------")


# populate_users()
# display_users()
# print(authentication("john","111"))


if __name__ == '__main__':
    conn = set_up_db()
    drop_database(conn, DATABASE_NAME)
    #populate_users()
    
    #test_functions()
    
    #test_user_response_dict()
    
    # print(authentication("john","111"))
    # print(authentication("lxx","111"))
    conn.close()