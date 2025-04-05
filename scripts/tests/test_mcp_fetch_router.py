import requests

def main():
    url = "http://localhost:8109/fetch"
    try:
        response = requests.get(url, stream=True, timeout=5)
        print(f"Status code: {response.status_code}")
        print("Headers:", response.headers)
        # Read a small part of the stream to verify connection
        chunk = next(response.iter_content(chunk_size=1024))
        print("Received data chunk:", chunk[:200])
    except Exception as e:
        print(f"Failed to connect or fetch data: {e}")

if __name__ == "__main__":
    main()