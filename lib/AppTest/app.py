from flask import Flask, render_template, json, request



app = Flask(__name__)

@app.route("/")
def main():
    return render_template('index.html')

@app.route('/showNewUser')
def showNewUser():
    return render_template('NewUser.html')

@app.route('/Recommend', methods=['POST'])
def Recommend():
    _movie1 = str(request.form['movie1'])
    #t1 = str(type(_movie1))
    _movie2 = str(request.form['movie2'])
    _movie3 = str(request.form['movie3'])
    _rate1 = int(request.form['rate1'])
    _rate2 = int(request.form['rate2'])
    _rate3 = int(request.form['rate3'])
    # # if _movie1 and _movie2 and _movie3 and _rate1 and _rate2 and _rate3:
    #     return json.dumps({'html':'<span>All fields good !!</span>'})
    # else:
    #     return json.dumps({'html':'<span>Enter the required fields</span>'})

    #return json.dumps({'status':'OK','user':_movie1,'pass':_rate1})
    _movie1 = json.dumps(_movie1)
    data = [{"title" : "This is a movie","imgUrl" :  "http://design.bigbangfish.com/wp-content/uploads/disney-cartoons/Shaun-the-Sheep/Shaun-the-Sheep-pictures-3.jpg"}]
    # Writing JSON data
    with open('static/js/data.json', 'w') as f:
      json.dump(data,f)

    return render_template('NewUser.html', mov1p2 = "http://www.amazon.com/", mov1p1 = _movie1)
    #return render_template('index.html', obj = _movie1)
    #return redirect('')

if __name__ == "__main__":
    app.run()

