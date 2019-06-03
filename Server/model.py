class Response:
    def __init__(self, type, status, source=1, message=None, contents=None):
        self.message_type = type
        self.message_content = message
        self.status = status
        self.source = 1
        self.contents = contents

    def to_dict(self):
        if self.contents is None:
            return {
                'type': self.message_type,
                'status': self.status,
                'message': self.message_content,
                'source': self.source
            }
        elif self.message_content is None:
            return {
                'type': self.message_type,
                'status': self.status,
                'source': self.source,
                'contents': self.contents
            }
        else:
            return {
                'type': self.message_type,
                'status': self.status,
                'message': self.message_content,
                'source': self.source,
                'contents': self.contents
            }

class FulfillmentText:
    def __init__(self, fulfillmentText):
        self.fulfillmentText = fulfillmentText

    def to_dict(self):
        return {
            'fulfillmentText' : self.fulfillmentText
        }

class Track:
    def __init__(self, name, uri, image=None):
        self.name = name
        self.uri = uri
        self.image = image


    def to_dict(self):
        if self.image is None:
            return {
                'name': self.name,
                'uri': self.uri,
            }
        else:
            return {
                'name' : self.name,
                'uri' : self.uri,
                'image' : self.image,
            }

class Playlist(Track):
    def __init__(self, name, uri, total=None, image=None):
        super(Playlist, self).__init__(name, uri, image)
        self.total = total

    def to_dict(self):
        return {
            'name' : self.name,
            'uri' : self.uri,
            'image' : self.image,
            'total' : self.total
        }

class Movie:
    def __init__(self, name, year, type):
        self.name = name
        self.year = year
        self.type = type

    def to_dict(self):
        return {
            'name': self.name + ' (' + str(self.year) + ')',
            'title': self.name,
            'year': self.year,
            'uri':self.type
        }

class Video:
    def __init__(self, video_id, thumbnail):
        self.video_id = video_id
        self.thumbnail = thumbnail

    def to_dict(self):
        return {
            'videoId' : self.video_id,
            'thumbnail' : self.thumbnail
        }


class Music_Instruction:
    def __init__(self, instruction):
        self.instruction = instruction

    def to_dict(self):
        return {
            'order': self.instruction
        }

class Selection:

    def __init__(self, list_type, number, type_of_info=None):
        self.list_type = list_type
        self.number = number
        self.type_of_info = type_of_info

    def to_dict(self):

        if self.type_of_info is None:
            return {
                'type': self.list_type,
                'number': self.number  # 第几个
            }

        else:
            return {
                'infotype': self.type_of_info,  # type of info
                'type' : self.list_type,
                'number' : self.number  # 第几个
            }
