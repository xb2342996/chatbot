import requests

# lifx light bulb
LIGHT_CONTROL_URL = 'https://api.lifx.com/v1/lights'
LIFX_ACCESS_TOKEN = 'cd237f1ec08865524355931f57b751628ab29c93d9fb6ad553d2691010fa0ff8'
BUILT_IN_COLOR = {'white', 'red', 'orange', 'yellow', 'cyan', 'green', 'blue', 'purple', 'pink'}

# get CONST_COLOR from http://www.discoveryplayground.com/computer-programming-for-kids/rgb-colors/
CONST_COLOR = {'snow': [255, 250, 250], 'snow 2': [238, 233, 233], 'snow 3': [205, 201, 201], 'snow 4': [139, 137, 137],
               'ghost white': [248, 248, 255], 'white smoke': [245, 245, 245], 'gainsboro': [220, 220, 220],
               'floral white': [255, 250, 240], 'old lace': [253, 245, 230], 'linen': [240, 240, 230],
               'antique white': [250, 235, 215], 'antique white 2': [238, 223, 204], 'antique white 3': [205, 192, 176],
               'antique white 4': [139, 131, 120], 'papaya whip': [255, 239, 213], 'blanched almond': [255, 235, 205],
               'bisque': [255, 228, 196], 'bisque 2': [238, 213, 183], 'bisque 3': [205, 183, 158],
               'bisque 4': [139, 125, 107], 'peach puff': [255, 218, 185], 'peach puff 2': [238, 203, 173],
               'peach puff 3': [205, 175, 149], 'peach puff 4': [139, 119, 101], 'navajo white': [255, 222, 173],
               'moccasin': [255, 228, 181], 'cornsilk': [255, 248, 220], 'cornsilk 2': [238, 232, 205],
               'cornsilk 3': [205, 200, 177], 'cornsilk 4': [139, 136, 120], 'ivory': [255, 255, 240],
               'ivory 2': [238, 238, 224], 'ivory 3': [205, 205, 193], 'ivory 4': [139, 139, 131],
               'lemon chiffon': [255, 250, 205], 'seashell': [255, 245, 238], 'seashell 2': [238, 229, 222],
               'seashell 3': [205, 197, 191], 'seashell 4': [139, 134, 130], 'honeydew': [240, 255, 240],
               'honeydew 2': [244, 238, 224], 'honeydew 3': [193, 205, 193], 'honeydew 4': [131, 139, 131],
               'mint cream': [245, 255, 250], 'azure': [240, 255, 255], 'alice blue': [240, 248, 255],
               'lavender': [230, 230, 250], 'lavender blush': [255, 240, 245], 'misty rose': [255, 228, 225],
               'white': [255, 255, 255], 'black': [0, 0, 0], 'dark slate gray': [49, 79, 79],
               'dim gray': [105, 105, 105], 'slate gray': [112, 138, 144], 'light slate gray': [119, 136, 153],
               'gray': [190, 190, 190], 'light gray': [211, 211, 211], 'midnight blue': [25, 25, 112],
               'navy': [0, 0, 128], 'cornflower blue': [100, 149, 237], 'dark slate blue': [72, 61, 139],
               'slate blue': [106, 90, 205], 'medium slate blue': [123, 104, 238], 'light slate blue': [132, 112, 255],
               'medium blue': [0, 0, 205], 'royal blue': [65, 105, 225], 'blue': [0, 0, 255],
               'dodger blue': [30, 144, 255], 'deep sky blue': [0, 191, 255], 'sky blue': [135, 206, 250],
               'light sky blue': [135, 206, 250], 'steel blue': [70, 130, 180], 'light steel blue': [176, 196, 222],
               'light blue': [173, 216, 230], 'powder blue': [176, 224, 230], 'pale turquoise': [175, 238, 238],
               'dark turquoise': [0, 206, 209], 'medium turquoise': [72, 209, 204], 'turquoise': [64, 224, 208],
               'cyan': [0, 255, 255], 'light cyan': [224, 255, 255], 'cadet blue': [95, 158, 160],
               'medium aquamarine': [102, 205, 170], 'aquamarine': [127, 255, 212], 'dark green': [0, 100, 0],
               'dark olive green': [85, 107, 47], 'dark sea green': [143, 188, 143], 'sea green': [46, 139, 87],
               'medium sea green': [60, 179, 113], 'light sea green': [32, 178, 170], 'pale green': [152, 251, 152],
               'spring green': [0, 255, 127], 'lawn green': [124, 252, 0], 'chartreuse': [127, 255, 0],
               'medium spring green': [0, 250, 154], 'green yellow': [173, 255, 47], 'lime green': [50, 205, 50],
               'yellow green': [154, 205, 50], 'forest green': [34, 139, 34], 'olive drab': [107, 142, 35],
               'dark khaki': [189, 183, 107], 'khaki': [240, 230, 140], 'pale goldenrod': [238, 232, 170],
               'light goldenrod yellow': [250, 250, 210], 'light yellow': [255, 255, 224], 'yellow': [255, 255, 0],
               'gold': [255, 215, 0], 'light goldenrod': [238, 221, 130], 'goldenrod': [218, 165, 32],
               'dark goldenrod': [184, 134, 11], 'rosy brown': [188, 143, 143], 'indian red': [205, 92, 92],
               'saddle brown': [139, 69, 19], 'sienna': [160, 82, 45], 'peru': [205, 133, 63],
               'burlywood': [222, 184, 135], 'beige': [245, 245, 220], 'wheat': [245, 222, 179],
               'sandy brown': [244, 164, 96], 'tan': [210, 180, 140], 'chocolate': [210, 105, 30],
               'firebrick': [178, 34, 34], 'brown': [165, 42, 42], 'dark salmon': [233, 150, 122],
               'salmon': [250, 128, 114], 'light salmon': [255, 160, 122], 'orange': [255, 165, 0],
               'dark orange': [255, 140, 0], 'coral': [255, 127, 80], 'light coral': [240, 128, 128],
               'tomato': [255, 99, 71], 'orange red': [255, 69, 0], 'red': [255, 0, 0], 'hot pink': [255, 105, 180],
               'deep pink': [255, 20, 147], 'pink': [255, 192, 203], 'light pink': [255, 182, 193],
               'pale violet red': [219, 112, 147], 'maroon': [176, 48, 96], 'medium violet red': [199, 21, 133],
               'violet red': [208, 32, 144], 'violet': [238, 130, 238], 'plum': [221, 160, 221],
               'orchid': [218, 112, 214], 'medium orchid': [186, 85, 211], 'dark orchid': [153, 50, 204],
               'dark violet': [148, 0, 211], 'blue violet': [138, 43, 226], 'purple': [160, 32, 240],
               'medium purple': [147, 112, 219], 'thistle': [216, 191, 216]}

# get light control request headers
def get_light_request_header(token):
    headers = {
        "Authorization": "Bearer %s" % token
    }
    return headers


'''
Light control interface 

Parameter:
    token : String (required)
        access_token written in app.py (constant)
        
    power : String (required)
        'on' : light on
        'off' : light off
        
    duration: String
        How long in seconds you want the power action to take.
        
    color: String  
        The color to set the light to. see https://api.developer.lifx.com/v1/docs/colors
        
    brightness:	double
        The brightness level from 0.0 to 1.0. Overrides any brightness set in color (if any).
        
    infrared:	double
        The maximum brightness of the infrared channel from 0.0 to 1.0.
        
Return status code see below
    A_OK_HTTP_CODES = [
        200,
        207
    ]
    
    A_ERROR_HTTP_CODES = {
        400: "Request was invalid",
        401: "Invalid API key",
        403: "Bad OAuth scope",
        404: "Selector did not match any lights",
        422: "Missing or malformed parameters",
        426: "HTTP is required to perform transaction",
        # see http://api.developer.lifx.com/v1/docs/rate-limits
        429: "Rate limit exceeded",
        500: "API currently unavailable",
        502: "API currently unavailable",
        503: "API currently unavailable",
        523: "API currently unavailable"
    }
'''


def light_control(token, power, duration, brightness, color, infrared, res_list):
    headers = get_light_request_header(token)
    data = {}
    speech = ''
    data['power'] = power
    if duration != None:
        data['duration'] = duration
    if brightness != None:
        data['brightness'] = brightness
    if color != None:
        data['color'] = color[0]
    if infrared != None:
        data['infrared'] = infrared

    response = requests.put(LIGHT_CONTROL_URL + '/all/state', data=data, headers=headers)
    res_status = response.status_code
    if res_status == 207:
        if 'power' in res_list:
            speech += "The light is " + power + ". "
        if 'duration' in res_list:
            speech += "The duration is changed to " + duration + ' . '
        if 'brightness' in res_list:
            #  speech += "The brightness is changed to " + str(brightness)[:5] + ' . '
            speech += "The brightness has changed. "

        if 'color' in res_list:
            if color[1] == 'neutralwhite' or color[1] == 'warmwhite' or color[1] == 'coolwhite':
                speech += "The light is changed to " + color[1] + " mode. "
            elif color[1] == 'whitesmode':
                speech += "The light is turn on the whites light mode. "
            elif color[1] == 'cooler' or color[1] == 'warmer':
                speech += "The light is " + color[1] + " now. "
            else:
                speech += "The light is set to " + color[1]
        if 'infrared' in res_list:
            speech += "The infrared has set to be " + str(infrared)
    if res_status == 422:
        speech = 'sorry, the color does not have a valid value'
    if res_status == 429:
        speech = "sorry, i can't manage with too many request, could you request it one at a time"
    if res_status == 400:
        speech = 'sorry,request was invalid'

    return {"fulfillmentText": speech}

# get state information for the light
def get_last(token):
    headers = get_light_request_header(token)
    response = requests.get(LIGHT_CONTROL_URL + '/all', headers=headers).json()
    power = response[0]['power']
    brightness = response[0]['brightness']
    color = response[0]['color']
    kelvin = response[0]['color']['kelvin']
    connected = response[0]['connected']
    return power, brightness, color, kelvin, connected




# change rgb space to hue-saturation-brightness space
def rgb_to_hsb(rgb_list):
    r, g, b = rgb_list
    M = max(r, g, b)
    m = min(r, g, b)
    c = M - m
    if M == r:
        h0 = ((g - b) / c) % 6
    elif M == g:
        h0 = (b - r) / c + 2
    elif M == b:
        h0 = (r - g) / c + 4
    hue = 60 * h0
    brightness = M / 255
    saturation = (M - m) / M
    return "hue:" + str(hue) + " brightness:" + str(brightness) + ' saturation:' + str(saturation)


# kelvin:[1500-9000]
# brightness:[0.0-1.0]
def thresholdExceeded(text, value):
    if text == 'kelvin' and value <= 9000 and value >= 1500:
        return False
    elif text == 'brightness' and value <= 1.0 and value >= 0.0:
        return False
    return True



def issame(name, value1, value2):
    if name == 'hue':
        if abs(value1 - value2) < 0.1:
            return True
        return False
    elif name == 'brightness':
        if abs(value1 - value2) < 0.0001:
            return True
        return False
    elif name == 'kelvin':
        if abs(value1 - value2) < 0.1:
            return True
        return False

class LightController:
    def __init__(self, lightcontext):
        speech=None
        last_power, last_brightness, last_color, last_kelvin, connected = get_last(LIFX_ACCESS_TOKEN)  # get last state
        if not connected:
            speech = 'The light is offline. Please check your light. '
        res_list = []
        power, brightness, color = None, None, None
        percentage = None

        # set light on or off
        if 'LightOnOff' in lightcontext and len(lightcontext['LightOnOff']) != 0:
            if lightcontext['LightOnOff'][0] == 'LightOff':  # changed
                power = 'off'
                res_list.append('power')
            else:
                power = 'on'
                if last_power != 'on':  # changed
                    res_list.append('power')

        # set light color
        if 'LightColor' in lightcontext and len(lightcontext['LightColor']) != 0:
            res_list.append('color')
            speech = None
            original_color = lightcontext['LightColor'][0].lower()  # pink
            if original_color in BUILT_IN_COLOR:
                color = (original_color, original_color)
            elif original_color in CONST_COLOR:
                rgb_list = CONST_COLOR[lightcontext["LightColor"][0]]  # pink rgb
                hsb_color = (rgb_to_hsb(rgb_list))  # pink hsb string
                if not issame('hue', last_color['hue'], float(hsb_color.split(" ")[0][4:])):  # hue changed
                    color = (hsb_color,
                             original_color)  # 'hue:210.0 brightness:0.2627450980392157 saturation:0.6567164179104478', pink
                else:
                    color = None  # the same
            else:
                speech = "Sorry the light cannot set to " + original_color + ". "  # cannot find in CONST_RGB

        # get percentage for setting the brightness control
        if 'LightBrightnessPercentage' in lightcontext and len(lightcontext['LightBrightnessPercentage']) != 0:
            percentage = lightcontext["LightBrightnessPercentage"][0]
            percentage = (float(percentage.strip('%'))) / 100  # 0.6
            if 'LightBrightness' not in lightcontext:  # 40%
                if thresholdExceeded('brightness', percentage):
                    speech = "Sorry brightness degree exceeded. "
                else:
                    brightness = percentage
                    res_list.append('brightness')
            if 'LightBrightness' in lightcontext and len(lightcontext['LightBrightness']) == 0:  # 30%
                if thresholdExceeded('brightness', percentage):
                    speech = "Sorry brightness degree exceeded. "
                else:
                    brightness = percentage
                    res_list.append('brightness')

        # get light brightness key word
        if 'LightBrightness' in lightcontext and len(lightcontext['LightBrightness']) != 0:
            brightness_list = lightcontext["LightBrightness"]
            res_list.append('brightness')
            if 'brightest' in brightness_list:  # brightest
                brightness = 1.0
            elif 'brighter' in brightness_list:
                if 'by' in brightness_list and 'LightBrightnessPercentage' in lightcontext and len(
                        lightcontext["LightBrightnessPercentage"]) != 0:  # turn up by 10% brightness
                    brightness = last_brightness + percentage
                elif 'LightBrightnessPercentage' not in lightcontext or len(
                        lightcontext['LightBrightnessPercentage']) != 0:  # 10% brighter
                    brightness = percentage
                else:  # make the room brighter
                    brightness = last_brightness + 0.3
            elif 'dim' in brightness_list:
                if 'by' in brightness_list and 'LightBrightnessPercentage' in lightcontext and len(
                        lightcontext["LightBrightnessPercentage"]) != 0:  # dim by 10%
                    brightness = last_brightness - percentage
                elif 'LightBrightnessPercentage' not in lightcontext or len(
                        lightcontext['LightBrightnessPercentage']) != 0:  # 10% darker
                    brightness = percentage
                else:  # make the room darker
                    brightness = last_brightness - 0.3

            elif brightness_list == ['brightness']:
                if 'LightBrightnessPercentage' in lightcontext and len(
                        lightcontext['LightBrightnessPercentage']) != 0:  # set brightness to 40%
                    brightness = percentage
                elif 'LightBrightnessPercentage' not in lightcontext:  # set brightness to 40%
                    brightness = percentage
                else:
                    # brightness = None
                    speech = "Sorry RelaxBot cannot understand your request about brightness. "
            else:
                # brightness = None
                speech = "Sorry RelaxBot cannot understand your request about brightness. "

            if thresholdExceeded('brightness', brightness):
                speech = "Sorry brightness degree exceeded. "

        # set kelvin paremater according to the cool white, warm white....
        if 'LightWhitesTune' in lightcontext and len(lightcontext['LightWhitesTune']) != 0:
            whites_list = lightcontext["LightWhitesTune"]
            res_list.append('color')
            value = None
            if whites_list == ['whitesmode']:  # turn on whites mode (default: 4300K white)
                value = 4300
                color = ('kelvin:4300', 'neutralwhite')
            if 'coolwhite' in whites_list:  # coolwhite mode 5300+
                value = 5600
                color = ('kelvin:5600', 'coolwhite')
            elif 'warmwhite' in whites_list:  # warmwhite mode 3300-
                value = 3000
                color = ('kelvin:3000', 'warmwhite')
            elif 'neutralwhite' in whites_list:  # neutralwhite mode 3300~5300
                value = 4300
                color = ('kelvin:4300', 'neutralwhite')
            if 'cooler' in whites_list:
                value = last_kelvin + 300
                color = ('kelvin:' + str(last_kelvin + 300), 'cooler')
            elif 'warmer' in whites_list:
                value = last_kelvin - 300
                color = ('kelvin:' + str(last_kelvin - 300), 'warmer')
            if thresholdExceeded('kelvin', value):
                speech = "Sorry kelvin exceeded. "
        self.brightness = brightness
        self.color = color
        self.power = power
        self.res_list = res_list
        self.speech = speech

    def to_response(self):
        if self.speech:
            return {"fulfillmentText": self.speech}
        else:
            return light_control(LIFX_ACCESS_TOKEN, self.power, None, self.brightness, self.color, None, self.res_list)
