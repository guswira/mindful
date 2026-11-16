import 'package:flutter_test/flutter_test.dart';
import 'package:mindful/features/exercise/data/calm_voice_picker.dart';

void main() {
  group('pickCalmVoice', () {
    test('iOS: prefers premium over enhanced over compact, skips robotic', () {
      final voices = [
        {
          'name': 'Fred',
          'locale': 'en-US',
          'quality': 'default',
          'identifier': 'com.apple.speech.synthesis.voice.Fred',
        },
        {
          'name': 'Eddy',
          'locale': 'en-US',
          'quality': 'enhanced',
          'identifier': 'com.apple.eloquence.en-US.Eddy',
        },
        {
          'name': 'Samantha',
          'locale': 'en-US',
          'quality': 'default',
          'identifier': 'com.apple.voice.compact.en-US.Samantha',
        },
        {
          'name': 'Ava',
          'locale': 'en-US',
          'quality': 'premium',
          'gender': 'female',
          'identifier': 'com.apple.voice.premium.en-US.Ava',
        },
        {
          'name': 'Damayanti',
          'locale': 'id-ID',
          'quality': 'enhanced',
          'identifier': 'com.apple.voice.enhanced.id-ID.Damayanti',
        },
      ];

      expect(pickCalmVoice(voices, 'en')?['name'], 'Ava');
      expect(pickCalmVoice(voices, 'id')?['name'], 'Damayanti');
    });

    test('Android: offline high quality beats network, skips uninstalled', () {
      final voices = [
        {
          'name': 'en-us-x-iol-network',
          'locale': 'en-US',
          'quality': 'high',
          'network_required': '1',
        },
        {
          'name': 'en-us-x-sfg-local',
          'locale': 'en-US',
          'quality': 'high',
          'network_required': '0',
        },
        {
          'name': 'en-us-x-tpd-local',
          'locale': 'en-US',
          'quality': 'very high',
          'network_required': '0',
          'features': 'notInstalled',
        },
        {
          'name': 'in-id-x-dfz-local',
          'locale': 'in-ID',
          'quality': 'normal',
          'network_required': '0',
        },
      ];

      expect(pickCalmVoice(voices, 'en')?['name'], 'en-us-x-sfg-local');
      expect(pickCalmVoice(voices, 'id')?['name'], 'in-id-x-dfz-local');
    });

    test('web: prefers neural voices', () {
      final voices = [
        {'name': 'Samantha', 'locale': 'en-US'},
        {
          'name': 'Microsoft Aria Online (Natural) - English (United States)',
          'locale': 'en-US',
        },
      ];

      expect(pickCalmVoice(voices, 'en')?['name'], contains('Aria'));
    });

    test('null when no voice speaks the language', () {
      expect(
        pickCalmVoice([
          {'name': 'Ava', 'locale': 'en-US'},
        ], 'id'),
        isNull,
      );
    });
  });
}
