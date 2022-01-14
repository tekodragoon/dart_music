import 'package:flutter/material.dart';
import 'music.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Dart Music',
      theme: new ThemeData(
        primarySwatch: Colors.blue
      ),
      debugShowCheckedModeBanner: false,
      home: new Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _Home();
  }
}

class _Home extends State<Home> {

  List<Music> musicList = [
    new Music('Swift theme', 'Codabee',
        'Images/un.jpg', 'https://codabee.com/wp-content/uploads/2018/06/un.mp3'),
    new Music('Flutter theme', 'Codabee',
        "Images/deux.jpg", 'https://codabee.com/wp-content/uploads/2018/06/deux.mp3')
  ];
  Music actualMusic;
  Duration musicPosition = new Duration(seconds: 0);
  Duration musicLength = new Duration(seconds: 30);
  AudioPlayer audioPlayer;
  PlayerState musicPlayerState = PlayerState.stopped;
  int musicIndex;

  @override
  void initState() {
    super.initState();
    musicIndex = 0;
    actualMusic = musicList[musicIndex];
    configAudioPlayer();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          'Coda Music',
          style: new TextStyle(
            color: Colors.white
          ),
        ),
        elevation: 5.0,
        backgroundColor: Colors.black54,
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[700],
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget> [
            new Card(
              elevation: 10.0,
              child: new Container(
                width: MediaQuery.of(context).size.height * 0.4,
                child: Image.asset(actualMusic.imagePath),
              ),
            ),
            bodyText(actualMusic.title, 1.2),
            bodyText(actualMusic.artistName,1.0),
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                bodyButton(Icons.fast_rewind, 30.0, ActionButton.rewind),
                bodyButton(
                    musicPlayerState == PlayerState.playing ? Icons.pause : Icons.play_arrow,
                    60.0,
                    musicPlayerState == PlayerState.playing ? ActionButton.pause : ActionButton.play),
                bodyButton(Icons.fast_forward, 30.0, ActionButton.forward)
              ],
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget> [
                bodyText(fromDuration(musicPosition), 0.8),
                bodyText(fromDuration(musicLength), 0.8)
              ],
            ),
            new Slider(
                value: musicPosition.inSeconds.toDouble(),
                min: 0.0,
                max: musicLength.inSeconds.toDouble(),
                inactiveColor: Colors.white,
                activeColor:  Colors.red,
                onChanged: (double p) {
                  setState(() {
                    audioPlayer.seek(Duration(seconds: p.toInt()));
                  });
                }
            )
          ],
        ),
      )
    );
  }

  Text bodyText(String data, double scale) {
    return new Text(
      data,
      textScaleFactor: scale,
      textAlign: TextAlign.center,
      style: new TextStyle(
        color: Colors.white,
        fontSize: 20.0,
        fontWeight: FontWeight.bold
      ),
    );
  }

  IconButton bodyButton(IconData icon, double size, ActionButton action) {
    return new IconButton(
      iconSize: size,
      color: Colors.white,
      icon: new Icon(icon),
      onPressed: () {
        switch(action) {
          case ActionButton.play:
            play();
            break;
          case ActionButton.pause:
            pause();
            break;
          case ActionButton.forward:
            forward();
            break;
          case ActionButton.rewind:
            rewind();
            break;
        }
      });
  }

  void configAudioPlayer() {
    audioPlayer = new AudioPlayer();
    audioPlayer.onAudioPositionChanged.listen(
        (pos) => setState(() => musicPosition = pos)
    );
    audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == AudioPlayerState.STOPPED) {
        setState(() {
          musicPlayerState = PlayerState.stopped;
        });
      }
    }, onError: (message) {
      print('error: $message');
      setState(() {
        musicPlayerState = PlayerState.stopped;
        musicLength = new Duration(seconds: 0);
        musicPosition = new Duration(seconds: 0);
      });
    });
    audioPlayer.onDurationChanged.listen((Duration p) {
      setState(() {
        musicLength = p;
      });
    });
    audioPlayer.onPlayerCompletion.listen((event) {
     forward();
    });
    audioPlayer.setUrl(actualMusic.urlSong);
  }

  Future play() async {
    await audioPlayer.play(actualMusic.urlSong);
    setState(() {
      musicPlayerState = PlayerState.playing;
    });
  }

  Future pause() async {
    await audioPlayer.pause();
    setState(() {
      musicPlayerState = PlayerState.paused;
    });
  }

  void forward() {
    if (musicIndex < musicList.length - 1) {
      musicIndex++;
    } else {
      musicIndex = 0;
    }
    changeSong();
  }

  void rewind() {
    if (musicPosition > Duration(seconds: 3)) {
      audioPlayer.seek(Duration(seconds: 0));
    } else  {
      if (musicIndex > 0) {
        musicIndex--;
      }
      else {
        musicIndex = musicList.length - 1;
      }
      changeSong();
    }
  }

  void changeSong() {
    setState(() {
      actualMusic = musicList[musicIndex];
    });
    bool wasPlaying = audioPlayer.state == AudioPlayerState.PLAYING;
    audioPlayer.stop();
    configAudioPlayer();
    if (wasPlaying) {
      play();
    }
    else {
      audioPlayer.seek(Duration(seconds: 0));
    }
  }

  String fromDuration(Duration length) {
    return length.toString().split(".").first;
  }
}

enum ActionButton {
  play, pause, rewind, forward
}

enum PlayerState {
  playing, paused, stopped
}