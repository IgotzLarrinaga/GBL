import os
import glob
import re
import shutil
from tkinter import filedialog
from tkinter import Tk

def remove_records(file_path, output_folder):
    with open(file_path, 'r') as file:
        lines = file.readlines()

    with open(os.path.join(output_folder, os.path.basename(file_path)), 'w') as file:
        i = 0
        while i < len(lines):
            if '[Record 2]' in lines[i]:
                i += 3  
            else:
                file.write(lines[i])
                i += 1

def main():
    root = Tk()
    root.withdraw()  
    folder_selected = filedialog.askdirectory()  

    output_folder = os.path.join(folder_selected, 'out')
    os.makedirs(output_folder, exist_ok=True)

    log_files = glob.glob(os.path.join(folder_selected, '*.log'))

    for log_file in log_files:
        remove_records(log_file, output_folder)

if __name__ == "__main__":
    main()
