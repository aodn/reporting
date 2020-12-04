import os
from subprocess import run
from typing import List
from waitress import serve
from flask import Flask, render_template

app = Flask(__name__)

this_src_path = os.path.dirname(os.path.realpath(__file__))
report_statuses = os.path.join(this_src_path,'report_statuses')
report_logs = os.path.join(this_src_path,'report_logs')
checker_statuses = os.path.join(this_src_path,'checker_statuses')
checker_logs = os.path.join(this_src_path,'checker_logs')
figures = os.path.join(this_src_path,'figures/eMII_data_report/AATAMS_EmbargoPlots')


def list_folder(folder: str, sort: bool = True) -> List[str]:
    cmd = run(['ls', folder], capture_output=True)
    files = [x.decode() for x in cmd.stdout.split()]
    print(files)
    if sort:
        return sorted(files)[::-1]
    else:
        return files


def get_entry(entry: str, folder: str) -> (str, str):
    reports = list_folder(folder)
    current_available = entry == 'current' and len(reports) >= 1
    last_available = entry == 'previous' and len(reports) >= 2
    if current_available:
        return (folder, reports[0])
    if last_available:
        return (folder, reports[1])
    return (folder, 'not available')


def get_status(folder: str, file: str) -> str:
    fpath = os.path.join(folder, file)
    try:
        with open(fpath, 'r') as file:
            return file.readline()
    except FileNotFoundError:
        return ''


def get_log_content(folder: str, file: str) -> List[str]:
    fpath = os.path.join(folder, file)
    with open(fpath, 'r') as file:
        return file.read()


def create_status_table():
    _,current = get_entry('current', report_statuses)
    _,clog = get_entry('current', report_logs)
    _,previous = get_entry('previous', report_statuses)
    _,plog = get_entry('previous', report_logs)

    table = {
        'Current report created at ': current,
        'Current reporting status is': get_status(report_statuses, current),
        'Current checker status is': get_status(checker_statuses, current),
        '-----':'-----',
        'Previous report created at': previous,
        'Previous reporting status is': get_status(report_statuses, previous),
        'Previous checker status is': get_status(checker_statuses, previous)
    }
    return table


def update_embargo_image():
    folder, image = get_entry('current',figures)
    print(image)
    ipath = os.path.join(folder,image)
    stdout = run(['cp',ipath,'static/images/current_embargo.jpeg'],capture_output=True)
    pass

@app.route("/")
def index():
    stable = create_status_table()
    update_embargo_image()
    return render_template('index.html', result=stable)

@app.route("/last_log",methods=['GET'])
def last_log():
    content = get_log_content(*get_entry('current',report_logs))
    return render_template('rawfile.html',result=content)

@app.route("/previous_log",methods=['GET'])
def previous_log():
    content = get_log_content(*get_entry('previous',report_logs))
    return render_template('rawfile.html',result=content)


if __name__ == "__main__":
    serve(app,host='0.0.0.0',port=8000)
