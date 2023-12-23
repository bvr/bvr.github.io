
from icecream import ic

ic(10)

def plus333(i):
    return i + 333

def multiply5(i):
    return i * 5

ic(multiply5(plus333(123)))

d = {'key': {1: 'one'}}
ic(d['key'][1])

class klass():
    attr = 'yep'
ic(klass.attr)

data = {'data': [1,2,3,4,5], 'labels': ['a', 'b', 'c']}
ic(data)

json = {
    'metadata': {
        'version': 1.0,
        'generated_at': '2023-12-21'
    },
    'posts': [
        {
            'id': 1,
            'author': 'Roman',
            'posts': [
                {
                    'title': 'A title',
                    'contents': 'Contents of the file'
                }
            ]
        }
    ]
}

ic(json)
