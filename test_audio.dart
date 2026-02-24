import 'package:audioplayers/audioplayers.dart';

void main() async {
  await AudioCache.instance.loadAll(['pop.wav']);
}
