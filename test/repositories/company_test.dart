import 'package:cherry/models/index.dart';
import 'package:cherry/repositories-cubit/index.dart';
import 'package:cherry/util/index.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'mock.dart';

void main() {
  group('CompanyRepository', () {
    MockClient client;
    CompanyRepository repository;

    setUp(() {
      client = MockClient();
      repository = CompanyRepository(client);
    });

    test('throws AssertionError when client is null', () {
      expect(() => CompanyRepository(null), throwsAssertionError);
    });

    test('returns request when client returns 200', () async {
      final response = MockResponse();
      const json = {
        'headquarters': {
          'address': 'Rocket Road',
          'city': 'Hawthorne',
          'state': 'California'
        },
        'links': {
          'website': 'https://www.spacex.com/',
          'flickr': 'https://www.flickr.com/photos/spacex/',
          'twitter': 'https://twitter.com/SpaceX',
          'elon_twitter': 'https://twitter.com/elonmusk'
        },
        'name': 'SpaceX',
        'founder': 'Elon Musk',
        'founded': 2002,
        'employees': 8000,
        'vehicles': 3,
        'launch_sites': 3,
        'test_sites': 1,
        'ceo': 'Elon Musk',
        'cto': 'Elon Musk',
        'coo': 'Gwynne Shotwell',
        'cto_propulsion': 'Tom Mueller',
        'valuation': 52000000000,
        'summary':
            'SpaceX designs, manufactures and launches advanced rockets and spacecraft. The company was founded in 2002 to revolutionize space technology, with the ultimate goal of enabling people to live on other planets.',
        'id': '5eb75edc42fea42237d7f3ed'
      };

      when(response.data).thenReturn(json);
      when(
        client.get(Url.companyInformation),
      ).thenAnswer((_) => Future.value(response));

      final output = await repository.fetchData();
      expect(output, CompanyInfo.fromJson(json));
    });
  });
}
