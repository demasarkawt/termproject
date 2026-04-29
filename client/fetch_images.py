import urllib.request
import json
import urllib.parse
import time

places = [
    "Citadel of Erbil",
    "Qaysari Bazaar",
    "Mudhafaria Minaret",
    "Erbil Textile Museum",
    "Syriac Heritage Museum",
    "Sami Abdulrahman Park",
    "Shaqlawa",
    "Rawanduz Canyon",
    "Gali Ali Beg Waterfall",
    "Bekhal Waterfall",
    "Jundiyan Waterfall",
    "Zenta Waterfall",
    "Jalil Khayat Mosque",
    "Chaldean Catholic Church Erbil",
    "Amna Suraka",
    "Slemani Museum",
    "Azmar Mountain",
    "Dukan Lake",
    "Ahmed Awa Waterfall",
    "Tawela",
    "Grand Mosque of Sulaymaniyah",
    "Chavi Land",
    "Amedi",
    "Duhok Dam",
    "Gara Mountain",
    "Zakho Delal Bridge",
    "Gali Sheran",
    "Sipa Waterfall",
    "Lalish",
    "Halabja Monument",
    "Hawraman",
    "Byara",
    "Machko Chaikhana",
    "Abu Shihab Restaurant",
    "Family Mall Erbil"
]

results = {}

for place in places:
    print(f"Fetching {place}...")
    try:
        url = f"https://en.wikipedia.org/w/api.php?action=query&titles={urllib.parse.quote(place)}&prop=pageimages&format=json&pithumbsize=1000"
        req = urllib.request.Request(url, headers={'User-Agent': 'TravelAppBot/1.0 (contact: demas@example.com)'})
        with urllib.request.urlopen(req) as response:
            data = json.loads(response.read().decode())
            pages = data['query']['pages']
            found = False
            for page_id in pages:
                if 'thumbnail' in pages[page_id]:
                    results[place] = pages[page_id]['thumbnail']['source']
                    found = True
                else:
                    results[place] = None
            if not found:
                # Try a broader search if title doesn't match exactly
                search_url = f"https://en.wikipedia.org/w/api.php?action=query&list=search&srsearch={urllib.parse.quote(place)}&format=json"
                req_s = urllib.request.Request(search_url, headers={'User-Agent': 'TravelAppBot/1.0'})
                with urllib.request.urlopen(req_s) as resp_s:
                    s_data = json.loads(resp_s.read().decode())
                    if s_data['query']['search']:
                        top_title = s_data['query']['search'][0]['title']
                        img_url = f"https://en.wikipedia.org/w/api.php?action=query&titles={urllib.parse.quote(top_title)}&prop=pageimages&format=json&pithumbsize=1000"
                        req_i = urllib.request.Request(img_url, headers={'User-Agent': 'TravelAppBot/1.0'})
                        with urllib.request.urlopen(req_i) as resp_i:
                            i_data = json.loads(resp_i.read().decode())
                            i_pages = i_data['query']['pages']
                            for pid in i_pages:
                                if 'thumbnail' in i_pages[pid]:
                                    results[place] = i_pages[pid]['thumbnail']['source']
                                    found = True
        time.sleep(1.5) # Be polite
    except Exception as e:
        print(f"Error for {place}: {e}")
        results[place] = str(e)
        if "429" in str(e):
            print("Rate limited, sleeping for 10 seconds...")
            time.sleep(10)

with open('wiki_images.json', 'w') as f:
    json.dump(results, f, indent=4)

