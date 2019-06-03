import datetime,re,random
from model import FulfillmentText



def health(result):
    healthType = result.get("outputContexts")[0].get("parameters").get('HealthData')
    healthDate = result.get("outputContexts")[0].get("parameters").get('date-time')
    start_date, end_date = get_date(healthDate)
    if len(healthType)==1:
        healthType=healthType[0]
    elif len(healthType)==0:
        healthType='None'
    else:
        healthType = answer(healthType) 
    start_date,end_date = get_date(healthDate)  
    res = healthType+'#'+start_date+'#'+end_date
    # return speech
    return res


def is_empty(a):
    if len(a) == 0:
        return True
    else:
        return False

def get_date(healthDate):
    start_date = datetime.datetime.today().strftime('%Y-%m-%d')
    end_date = datetime.datetime.today().strftime('%Y-%m-%d')
    if not is_empty(healthDate):
        healthDate = healthDate[0]
        if type(healthDate)== dict:
            if "startDateTime" in healthDate:
                start_date = datetime.datetime(*map(int, re.split('[^\d]', healthDate.get('startDateTime'))[:-1])).strftime('%Y-%m-%d')
                end_date = datetime.datetime(*map(int, re.split('[^\d]', healthDate.get('endDateTime'))[:-1])).strftime('%Y-%m-%d')
            else:
                start_date = datetime.datetime(*map(int, re.split('[^\d]', healthDate.get('startDate'))[:-1])).strftime('%Y-%m-%d')
                end_date = datetime.datetime(*map(int, re.split('[^\d]', healthDate.get('endDate'))[:-1])).strftime('%Y-%m-%d')

        elif type(healthDate) == str:
            start_date = datetime.datetime(*map(int, re.split('[^\d]', healthDate)[:-1])).strftime('%Y-%m-%d')
            end_date = datetime.datetime(*map(int, re.split('[^\d]', healthDate)[:-1])).strftime('%Y-%m-%d')
    return start_date, end_date

def answer(a):
    text=''
    for i in a[:-1]:
        text+=f',{i}'
    text = text[1:]+','+a[-1]
    return text

def generate_res(health_type, start_date, end_date):
    msg=''
    health_type=health_type.split(',')[0]
    if start_date == end_date:
        randon_response=[
        f"{health_type} is comming up",
        f"{health_type} in {start_date} will be presented to you",
        f"here is your {health_type} in {start_date} ",
        f"here you are ^-^"
        ]
    else:
        randon_response=[
        f"{health_type} is comming up",
        f"{health_type} from {start_date} to {end_date} will be presented to you",
        f"here is your {health_type} between {start_date} to {end_date} ",
        f"here you are ^-^"
        ]
    msg = random.choice(randon_response)
    return msg