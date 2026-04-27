import urllib.request
import json

places = [
    "Erbil Citadel",
    "Qaysari Bazaar",
    "Mudhafaria Minaret",
    "Sami Abdulrahman Park",
    "Bekhal Waterfall",
    "Gali Ali Beg",
    "Shanadar Cave",
    "Amna Suraka",
    "Slemani Museum",
    "Sulaymaniyah",
    "Dukan Lake",
    "Azmar Mountain",
    "Ahmed Awa",
    "Grand Mosque of Sulaymaniyah",
    "Amedi",
    "Duhok Dam",
    "Zakho",
    "Lalish",
    "Halabja Monument",
    "Hawraman",
    "Kurdistan",
    "Zagros Mountains"
]

results = {}

for place in places:
    try:
        url = f"https://en.wikipedia.org/w/api.php?action=query&titles={urllib.parse.quote(place)}&prop=pageimages&format=json&pithumbsize=1000"
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req) as response:
            data = json.loads(response.read().decode())
            pages = data['query']['pages']
            for page_id in pages:
                if 'thumbnail' in pages[page_id]:
                    results[place] = pages[page_id]['thumbnail']['source']
                else:
                    results[place] = None
    except Exception as e:
        results[place] = str(e)

with open('wiki_images.json', 'w') as f:
    json.dump(results, f, indent=4)
