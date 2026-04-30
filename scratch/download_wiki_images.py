import os
import json
import subprocess
import urllib.parse
import time

# Paths
JSON_PATH = r'c:\Users\demas\OneDrive\Documents\GitHub\termproject\server\places.json'
IMAGE_DIR = r'c:\Users\demas\OneDrive\Documents\GitHub\termproject\client\assets\images'

# Browser-like User-Agent
USER_AGENT = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36'

def curl_get_json(url, params=None, retries=1):
    if params:
        url_with_params = url + '?' + urllib.parse.urlencode(params)
    else:
        url_with_params = url
    
    cmd = ["curl.exe", "-s", "-w", "\n%{http_code}", "-A", USER_AGENT, "-L", url_with_params]
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, encoding='utf-8', errors='ignore')
        if result.returncode == 0:
            lines = result.stdout.strip().split('\n')
            if not lines: return None
            status_code = lines[-1].strip()
            text = '\n'.join(lines[:-1]).strip()
            
            if status_code == "429" or not text or text.startswith('<!DOCTYPE html'):
                if retries > 0:
                    print(f"  [WARN] API Rate limited ({status_code}). Sleeping 60s...")
                    time.sleep(60)
                    return curl_get_json(url, params, retries - 1)
                else:
                    return None
            return json.loads(text)
    except Exception as e:
        pass
    return None

def curl_download(url, path):
    cmd = ["curl.exe", "-s", "-w", "%{http_code}", "-A", USER_AGENT, "-L", url, "-o", path]
    try:
        result = subprocess.run(cmd, capture_output=True, text=True)
        status_code = result.stdout.strip()
        if status_code == "200" and os.path.exists(path) and os.path.getsize(path) > 5000:
            return True
        elif status_code == "429":
            print("  [WARN] Download Rate limited (429). Sleeping 60s...")
            time.sleep(60)
            if os.path.exists(path): os.remove(path)
            return False
        else:
            if os.path.exists(path): os.remove(path)
            return False
    except Exception as e:
        print(f"  [ERROR] Curl Download failed: {e}")
    return False

def get_wiki_info(url):
    decoded_url = urllib.parse.unquote(url)
    is_commons = 'commons.wikimedia.org' in decoded_url
    base_url = "https://commons.wikimedia.org/w/api.php" if is_commons else "https://en.wikipedia.org/w/api.php"
    
    title = None
    if 'wiki/Category:' in decoded_url:
        title = 'Category:' + decoded_url.split('wiki/Category:')[1].split('?')[0]
    elif 'wiki/File:' in decoded_url:
        title = 'File:' + decoded_url.split('wiki/File:')[1].split('?')[0]
    elif 'wiki/' in decoded_url:
        title = decoded_url.split('wiki/')[1].split('?')[0]
    
    return base_url, title

def get_image_url(base_url, title):
    if not title: return None
    
    # 1. Category search
    if title.startswith('Category:'):
        params = {
            "action": "query",
            "format": "json",
            "list": "categorymembers",
            "cmtitle": title,
            "cmtype": "file",
            "cmlimit": 10
        }
        data = curl_get_json(base_url, params)
        if data:
            members = data.get('query', {}).get('categorymembers', [])
            for m in members:
                if any(ext in m['title'].lower() for ext in ['.jpg', '.jpeg', '.png']):
                    title = m['title']
                    break

    # 2. File info
    if title.startswith('File:'):
        params = {
            "action": "query",
            "format": "json",
            "prop": "imageinfo",
            "iiprop": "url",
            "titles": title
        }
        data = curl_get_json(base_url, params)
        if data:
            pages = data.get('query', {}).get('pages', {})
            for pid in pages:
                if 'imageinfo' in pages[pid]:
                    return pages[pid]['imageinfo'][0]['url']

    # 3. Page image info
    params = {
        "action": "query",
        "format": "json",
        "prop": "pageimages",
        "piprop": "original",
        "titles": title,
        "pithumbsize": 1000
    }
    data = curl_get_json(base_url, params)
    if data:
        pages = data.get('query', {}).get('pages', {})
        for pid in pages:
            if 'original' in pages[pid]:
                return pages[pid]['original']['source']
            if 'thumbnail' in pages[pid]:
                return pages[pid]['thumbnail']['source']
    
    # 4. Search fallback if nothing found
    if not title.startswith('Category:') and not title.startswith('File:'):
        params_s = {
            "action": "query",
            "format": "json",
            "list": "search",
            "srsearch": title.replace('_', ' '),
            "srlimit": 1
        }
        data_s = curl_get_json(base_url, params_s)
        if data_s and data_s.get('query', {}).get('search'):
            top_title = data_s['query']['search'][0]['title']
            return get_image_url(base_url, top_title)

    return None

def main():
    if not os.path.exists(IMAGE_DIR): os.makedirs(IMAGE_DIR)
    with open(JSON_PATH, 'r', encoding='utf-8') as f: data = json.load(f)
    
    places = data.get('places', [])
    print(f"Checking {len(places)} places in Kurdistan Go dataset...")
    
    downloaded_count = 0
    skipped_count = 0
    failed_count = 0

    for p in places:
        asset_path = p.get('image', '')
        if not asset_path.startswith('assets/images/'):
            skipped_count += 1
            continue
        
        local_path = os.path.join(IMAGE_DIR, os.path.basename(asset_path))
        if os.path.exists(local_path) and os.path.getsize(local_path) > 10000:
            skipped_count += 1
            continue
        
        url = p.get('wikimediaUrl', '')
        if not url:
            failed_count += 1
            continue
        
        print(f"[{p['id']}] Processing {p['title']}...")
        api_url, title = get_wiki_info(url)
        img_url = get_image_url(api_url, title)
        if not img_url:
            print(f"  Trying search fallback for: {p['title']}")
            img_url = get_image_url(api_url, p['title'])
        
        if img_url:
            if curl_download(img_url, local_path):
                print(f"  [DONE] Downloaded: {os.path.basename(local_path)} ({os.path.getsize(local_path)} bytes)")
                downloaded_count += 1
            else:
                print(f"  [FAIL] Failed to download: {os.path.basename(local_path)}")
                failed_count += 1
        else:
            print(f"  [FAIL] Image source not found for: {title}")
            failed_count += 1
        
        time.sleep(5)

    print("\n--- Summary ---")
    print(f"Total: {len(places)} | Downloaded: {downloaded_count} | Skipped: {skipped_count} | Failed: {failed_count}")

if __name__ == "__main__":
    main()
