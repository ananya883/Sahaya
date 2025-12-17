import requests
from bs4 import BeautifulSoup
import pandas as pd


url = "https://mausam.imd.gov.in/responsive/rainfallinformation.php"

resp = requests.get(url)
resp.raise_for_status() 
soup = BeautifulSoup(resp.text, 'html.parser')


tables = pd.read_html(resp.text)

print(f"Found {len(tables)} tables")


for i, tbl in enumerate(tables):
    print(f"--- Table {i} ---")
    print(tbl.head())


df = tables[0] 

df_wayanad = df[df['District'] == 'Wayanad']  

print(df_wayanad)


df_wayanad.to_csv("rainfall_wayanad.csv", index=False)
print("Saved rainfall data for Wayanad.")
