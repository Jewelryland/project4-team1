from flask import Flask, render_template, json, request



app = Flask(__name__)

@app.route("/")
def main():
    return render_template('index.html')

# @app.route('/showNewUser')
# def showNewUser():
#     return render_template('NewUser.html')

@app.route('/Recommend', methods=['POST'])
def Recommend():
    _movie1 = str(request.form['movie1'])
    _movie2 = str(request.form['movie2'])
    _movie3 = str(request.form['movie3'])
    _movie4 = str(request.form['movie4'])
    _movie5 = str(request.form['movie5'])
    _rate1 = int(request.form['rate1'])
    _rate2 = int(request.form['rate2'])
    _rate3 = int(request.form['rate3'])
    _rate3 = int(request.form['rate4'])
    _rate3 = int(request.form['rate5'])
    # # if _movie1 and _movie2 and _movie3 and _rate1 and _rate2 and _rate3:
    #     return json.dumps({'html':'<span>All fields good !!</span>'})
    # else:
    #     return json.dumps({'html':'<span>Enter the required fields</span>'})

    data = [{"title1" : _movie1,
    "imgUrl1" : "http://webneel.com/daily/sites/default/files/images/daily/02-2013/11-hard-candy-creative-movie-poster-design.jpg",
    "url1" : "http://www.amazon.com", "title2" : _movie2, 
    "imgUrl2" : "http://webneel.com/sites/default/files/images/blog/thumb-movipos.jpg",
    "url2" : "http://www.amazon.com", "title3" : _movie3,
    "imgUrl3" : "http://webneel.com/daily/sites/default/files/images/daily/02-2013/6-big-fish-creative-movie-poster-design.jpg",    
    "url3" : "http://www.amazon.com"}]
    # Writing JSON data
    with open('static/js/data.json', 'w') as f:
      json.dump(data,f)

    return render_template('index.html')
    #return json.dumps({'status':'OK','user':_movie1,'pass':_rate1})
    #return redirect('NewUser.html')

if __name__ == "__main__":
    app.run()

