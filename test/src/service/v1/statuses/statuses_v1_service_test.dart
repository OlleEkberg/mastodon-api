// Copyright 2022 Kato Shinya. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the conditions.

// 🌎 Project imports:
import 'package:mastodon_api/src/core/client/user_context.dart';
import 'package:mastodon_api/src/core/exception/mastodon_exception.dart';
import 'package:mastodon_api/src/service/entities/account.dart';
import 'package:mastodon_api/src/service/entities/poll.dart';
import 'package:mastodon_api/src/service/entities/rate_limit.dart';
import 'package:mastodon_api/src/service/entities/status.dart';
import 'package:mastodon_api/src/service/entities/status_context.dart';
import 'package:mastodon_api/src/service/response/mastodon_response.dart';
import 'package:mastodon_api/src/service/v1/statuses/status_poll_param.dart';
import 'package:mastodon_api/src/service/v1/statuses/statuses_v1_service.dart';
// 📦 Package imports:
import 'package:test/test.dart';

import '../../../../mocks/client_context_stubs.dart' as context;
import '../../common_expectations.dart';

void main() {
  group('.createStatus', () {
    test('normal case', () async {
      final statusesService = StatusesV1Service(
        instance: 'test',
        context: context.buildPostStub(
          'test',
          UserContext.oauth2Only,
          '/api/v1/statuses',
          'test/src/service/v1/statuses/data/create_status.json',
        ),
      );

      final response = await statusesService.createStatus(
        text: 'Hello, World!',
        poll: StatusPollParam(
          options: ['test1', 'test2'],
          expiresIn: Duration(days: 10),
        ),
      );

      expect(response, isA<MastodonResponse>());
      expect(response.rateLimit, isA<RateLimit>());
      expect(response.data, isA<Status>());
      expect(response.data.id, '109384580642337706');
    });

    test('when unauthorized', () async {
      final statusesService = StatusesV1Service(
        instance: 'test',
        context: context.buildPostStub(
          'test',
          UserContext.oauth2Only,
          '/api/v1/statuses',
          'test/src/service/v1/statuses/data/create_status.json',
          statusCode: 401,
        ),
      );

      expectUnauthorizedException(
        () async => await statusesService.createStatus(text: 'Hello, World!'),
      );
    });

    test('when rate limit exceeded', () async {
      final statusesService = StatusesV1Service(
        instance: 'test',
        context: context.buildPostStub(
          'test',
          UserContext.oauth2Only,
          '/api/v1/statuses',
          'test/src/service/v1/statuses/data/create_status.json',
          statusCode: 429,
        ),
      );

      expectRateLimitExceededException(
        () async => await statusesService.createStatus(text: 'Hello, World!'),
      );
    });
  });

  group('.lookupPollById', () {
    test('normal case', () async {
      final statusesService = StatusesV1Service(
        instance: 'test',
        context: context.buildGetStub(
          'test',
          UserContext.oauth2OrAnonymous,
          '/api/v1/polls/1234',
          'test/src/service/v1/statuses/data/lookup_poll_by_id.json',
          {},
        ),
      );

      final response = await statusesService.lookupPollById(
        pollId: '1234',
      );

      expect(response, isA<MastodonResponse>());
      expect(response.rateLimit, isA<RateLimit>());
      expect(response.data, isA<Poll>());
    });

    test('when unauthorized', () async {
      final statusesService = StatusesV1Service(
        instance: 'test',
        context: context.buildGetStub(
          'test',
          UserContext.oauth2OrAnonymous,
          '/api/v1/polls/1234',
          'test/src/service/v1/statuses/data/lookup_poll_by_id.json',
          statusCode: 401,
          {},
        ),
      );

      expectUnauthorizedException(
        () async => await statusesService.lookupPollById(
          pollId: '1234',
        ),
      );
    });

    test('when rate limit exceeded', () async {
      final statusesService = StatusesV1Service(
        instance: 'test',
        context: context.buildGetStub(
          'test',
          UserContext.oauth2OrAnonymous,
          '/api/v1/polls/1234',
          'test/src/service/v1/statuses/data/lookup_poll_by_id.json',
          statusCode: 429,
          {},
        ),
      );

      expectRateLimitExceededException(
        () async => await statusesService.lookupPollById(
          pollId: '1234',
        ),
      );
    });
  });

  group('.createVote', () {
    test('normal case', () async {
      final statusesService = StatusesV1Service(
        instance: 'test',
        context: context.buildPostStub(
          'test',
          UserContext.oauth2Only,
          '/api/v1/polls/1234/votes',
          'test/src/service/v1/statuses/data/create_vote.json',
        ),
      );

      final response = await statusesService.createVote(
        pollId: '1234',
        choice: 1,
      );

      expect(response, isA<MastodonResponse>());
      expect(response.rateLimit, isA<RateLimit>());
      expect(response.data, isA<Poll>());
    });

    test('when unauthorized', () async {
      final statusesService = StatusesV1Service(
        instance: 'test',
        context: context.buildPostStub(
          'test',
          UserContext.oauth2Only,
          '/api/v1/polls/1234/votes',
          'test/src/service/v1/statuses/data/create_vote.json',
          statusCode: 401,
        ),
      );

      expectUnauthorizedException(
        () async => await statusesService.createVote(
          pollId: '1234',
          choice: 1,
        ),
      );
    });

    test('when rate limit exceeded', () async {
      final statusesService = StatusesV1Service(
        instance: 'test',
        context: context.buildPostStub(
          'test',
          UserContext.oauth2Only,
          '/api/v1/polls/1234/votes',
          'test/src/service/v1/statuses/data/create_vote.json',
          statusCode: 429,
        ),
      );

      expectRateLimitExceededException(
        () async => await statusesService.createVote(
          pollId: '1234',
          choice: 1,
        ),
      );
    });

    test('when parameters are invalid', () async {
      final statusesService = StatusesV1Service(
        instance: 'test',
        context: context.buildPostStub(
          'test',
          UserContext.oauth2Only,
          '/api/v1/polls/1234/votes',
          'test/src/service/v1/statuses/data/create_vote.json',
          statusCode: 422,
        ),
      );

      expect(
        () async => await statusesService.createVote(
          pollId: '1234',
          choice: 1,
        ),
        throwsA(
          allOf(
            isA<MastodonException>(),
            predicate(
              (MastodonException e) =>
                  e.message ==
                  'Required parameter is missing or improperly formatted.',
            ),
          ),
        ),
      );
    });
  });

  group('.createVotes', () {
    test('normal case', () async {
      final statusesService = StatusesV1Service(
        instance: 'test',
        context: context.buildPostStub(
          'test',
          UserContext.oauth2Only,
          '/api/v1/polls/1234/votes',
          'test/src/service/v1/statuses/data/create_votes.json',
        ),
      );

      final response = await statusesService.createVotes(
        pollId: '1234',
        choices: [1, 2],
      );

      expect(response, isA<MastodonResponse>());
      expect(response.rateLimit, isA<RateLimit>());
      expect(response.data, isA<Poll>());
    });

    test('when unauthorized', () async {
      final statusesService = StatusesV1Service(
        instance: 'test',
        context: context.buildPostStub(
          'test',
          UserContext.oauth2Only,
          '/api/v1/polls/1234/votes',
          'test/src/service/v1/statuses/data/create_votes.json',
          statusCode: 401,
        ),
      );

      expectUnauthorizedException(
        () async => await statusesService.createVotes(
          pollId: '1234',
          choices: [1],
        ),
      );
    });

    test('when rate limit exceeded', () async {
      final statusesService = StatusesV1Service(
        instance: 'test',
        context: context.buildPostStub(
          'test',
          UserContext.oauth2Only,
          '/api/v1/polls/1234/votes',
          'test/src/service/v1/statuses/data/create_votes.json',
          statusCode: 429,
        ),
      );

      expectRateLimitExceededException(
        () async => await statusesService.createVotes(
          pollId: '1234',
          choices: [1],
        ),
      );
    });

    test('when parameters are invalid', () async {
      final statusesService = StatusesV1Service(
        instance: 'test',
        context: context.buildPostStub(
          'test',
          UserContext.oauth2Only,
          '/api/v1/polls/1234/votes',
          'test/src/service/v1/statuses/data/create_votes.json',
          statusCode: 422,
        ),
      );

      expect(
        () async => await statusesService.createVotes(
          pollId: '1234',
          choices: [1],
        ),
        throwsA(
          allOf(
            isA<MastodonException>(),
            predicate(
              (MastodonException e) =>
                  e.message ==
                  'Required parameter is missing or improperly formatted.',
            ),
          ),
        ),
      );
    });
  });

  group('.lookupStatus', () {
    test('normal case', () async {
      final statusesService = StatusesV1Service(
        instance: 'test',
        context: context.buildGetStub(
          'test',
          UserContext.oauth2OrAnonymous,
          '/api/v1/statuses/1234',
          'test/src/service/v1/statuses/data/lookup_status.json',
          {},
        ),
      );

      final response = await statusesService.lookupStatus(
        statusId: '1234',
      );

      expect(response, isA<MastodonResponse>());
      expect(response.rateLimit, isA<RateLimit>());
      expect(response.data, isA<Status>());
    });

    test('when unauthorized', () async {
      final statusesService = StatusesV1Service(
        instance: 'test',
        context: context.buildGetStub(
          'test',
          UserContext.oauth2OrAnonymous,
          '/api/v1/statuses/1234',
          'test/src/service/v1/statuses/data/lookup_status.json',
          statusCode: 401,
          {},
        ),
      );

      expectUnauthorizedException(
        () async => await statusesService.lookupStatus(
          statusId: '1234',
        ),
      );
    });

    test('when rate limit exceeded', () async {
      final statusesService = StatusesV1Service(
        instance: 'test',
        context: context.buildGetStub(
          'test',
          UserContext.oauth2OrAnonymous,
          '/api/v1/statuses/1234',
          'test/src/service/v1/statuses/data/lookup_status.json',
          statusCode: 429,
          {},
        ),
      );

      expectRateLimitExceededException(
        () async => await statusesService.lookupStatus(
          statusId: '1234'
        ),
      );
    });
  });

  group('.lookupStatusContext', () {
    test('normal case', () async {
      final statusesService = StatusesV1Service(
        instance: 'test',
        context: context.buildGetStub(
          'test',
          UserContext.oauth2OrAnonymous,
          '/api/v1/statuses/1234/context',
          'test/src/service/v1/statuses/data/lookup_status_context.json',
          {},
        ),
      );

      final response = await statusesService.lookupStatusContext(
        statusId: '1234',
      );

      expect(response, isA<MastodonResponse>());
      expect(response.rateLimit, isA<RateLimit>());
      expect(response.data, isA<StatusContext>());
    });

    test('when unauthorized', () async {
      final statusesService = StatusesV1Service(
        instance: 'test',
        context: context.buildGetStub(
          'test',
          UserContext.oauth2OrAnonymous,
          '/api/v1/statuses/1234/context',
          'test/src/service/v1/statuses/data/lookup_status_context.json',
          statusCode: 401,
          {},
        ),
      );

      expectUnauthorizedException(
        () async => await statusesService.lookupStatusContext(
          statusId: '1234',
        ),
      );
    });

    test('when rate limit exceeded', () async {
      final statusesService = StatusesV1Service(
        instance: 'test',
        context: context.buildGetStub(
          'test',
          UserContext.oauth2OrAnonymous,
          '/api/v1/statuses/1234/context',
          'test/src/service/v1/statuses/data/lookup_status_context.json',
          statusCode: 429,
          {},
        ),
      );

      expectRateLimitExceededException(
        () async => await statusesService.lookupStatusContext(
          statusId: '1234'
        ),
      );
    });
  });

  group('.lookupStatusRebloggedBy', () {
    test('normal case', () async {
      final statusesService = StatusesV1Service(
        instance: 'test',
        context: context.buildGetStub(
          'test',
          UserContext.oauth2OrAnonymous,
          '/api/v1/statuses/1234/reblogged_by',
          'test/src/service/v1/statuses/data/lookup_status_reblogged_by.json',
          {},
        ),
      );

      final response = await statusesService.lookupStatusRebloggedBy(
        statusId: '1234',
      );

      expect(response, isA<MastodonResponse>());
      expect(response.rateLimit, isA<RateLimit>());
      expect(response.data, isA<Account>());
    });

    test('when unauthorized', () async {
      final statusesService = StatusesV1Service(
        instance: 'test',
        context: context.buildGetStub(
          'test',
          UserContext.oauth2OrAnonymous,
          '/api/v1/statuses/1234/reblogged_by',
          'test/src/service/v1/statuses/data/lookup_status_reblogged_by.json',
          statusCode: 401,
          {},
        ),
      );

      expectUnauthorizedException(
        () async => await statusesService.lookupStatusRebloggedBy(
          statusId: '1234',
        ),
      );
    });

    test('when rate limit exceeded', () async {
      final statusesService = StatusesV1Service(
        instance: 'test',
        context: context.buildGetStub(
          'test',
          UserContext.oauth2OrAnonymous,
          '/api/v1/statuses/1234/reblogged_by',
          'test/src/service/v1/statuses/data/lookup_status_reblogged_by.json',
          statusCode: 429,
          {},
        ),
      );

      expectRateLimitExceededException(
        () async => await statusesService.lookupStatusRebloggedBy(
          statusId: '1234'
        ),
      );
    });
  });

  group('.lookupStatusFavouritedBy', () {
    test('normal case', () async {
      final statusesService = StatusesV1Service(
        instance: 'test',
        context: context.buildGetStub(
          'test',
          UserContext.oauth2OrAnonymous,
          '/api/v1/statuses/1234/favourited_by',
          'test/src/service/v1/statuses/data/lookup_status_favourited_by.json',
          {},
        ),
      );

      final response = await statusesService.lookupStatusFavouritedBy(
        statusId: '1234',
      );

      expect(response, isA<MastodonResponse>());
      expect(response.rateLimit, isA<RateLimit>());
      expect(response.data, isA<Account>());
    });

    test('when unauthorized', () async {
      final statusesService = StatusesV1Service(
        instance: 'test',
        context: context.buildGetStub(
          'test',
          UserContext.oauth2OrAnonymous,
          '/api/v1/statuses/1234/favourited_by',
          'test/src/service/v1/statuses/data/lookup_status_favourited_by.json',
          statusCode: 401,
          {},
        ),
      );

      expectUnauthorizedException(
        () async => await statusesService.lookupStatusFavouritedBy(
          statusId: '1234',
        ),
      );
    });

    test('when rate limit exceeded', () async {
      final statusesService = StatusesV1Service(
        instance: 'test',
        context: context.buildGetStub(
          'test',
          UserContext.oauth2OrAnonymous,
          '/api/v1/statuses/1234/favourited_by',
          'test/src/service/v1/statuses/data/lookup_status_favourited_by.json',
          statusCode: 429,
          {},
        ),
      );

      expectRateLimitExceededException(
        () async => await statusesService.lookupStatusFavouritedBy(
          statusId: '1234'
        ),
      );
    });
  });

  group('.favouriteStatus', () {
    test('normal case', () async {
      final statusesService = StatusesV1Service(
        instance: 'test',
        context: context.buildPostStub(
          'test',
          UserContext.oauth2Only,
          '/api/v1/statuses/1234/favourite',
          'test/src/service/v1/statuses/data/lookup_status.json',
        ),
      );

      final response = await statusesService.favouriteStatus(
        statusId: '1234',
      );

      expect(response, isA<MastodonResponse>());
      expect(response.rateLimit, isA<RateLimit>());
      expect(response.data, isA<Status>());
    });

    test('when unauthorized', () async {
      final statusesService = StatusesV1Service(
        instance: 'test',
        context: context.buildPostStub(
          'test',
          UserContext.oauth2Only,
          '/api/v1/statuses/1234/favourite',
          'test/src/service/v1/statuses/data/lookup_status.json',
          statusCode: 401,
        ),
      );

      expectUnauthorizedException(
        () async => await statusesService.favouriteStatus(
          statusId: '1234',
        ),
      );
    });
  });

  group('.unfavouriteStatus', () {
    test('normal case', () async {
      final statusesService = StatusesV1Service(
        instance: 'test',
        context: context.buildPostStub(
          'test',
          UserContext.oauth2Only,
          '/api/v1/statuses/1234/unfavourite',
          'test/src/service/v1/statuses/data/lookup_status.json',
        ),
      );

      final response = await statusesService.unfavouriteStatus(
        statusId: '1234',
      );

      expect(response, isA<MastodonResponse>());
      expect(response.rateLimit, isA<RateLimit>());
      expect(response.data, isA<Status>());
    });

    test('when unauthorized', () async {
      final statusesService = StatusesV1Service(
        instance: 'test',
        context: context.buildPostStub(
          'test',
          UserContext.oauth2Only,
          '/api/v1/statuses/1234/unfavourite',
          'test/src/service/v1/statuses/data/lookup_status.json',
          statusCode: 401,
        ),
      );

      expectUnauthorizedException(
        () async => await statusesService.unfavouriteStatus(
          statusId: '1234',
        ),
      );
    });
  });

  group('.reblogStatus', () {
    test('normal case', () async {
      final statusesService = StatusesV1Service(
        instance: 'test',
        context: context.buildPostStub(
          'test',
          UserContext.oauth2Only,
          '/api/v1/statuses/1234/reblog',
          'test/src/service/v1/statuses/data/lookup_status.json',
        ),
      );

      final response = await statusesService.reblogStatus(
        statusId: '1234',
      );

      expect(response, isA<MastodonResponse>());
      expect(response.rateLimit, isA<RateLimit>());
      expect(response.data, isA<Status>());
    });

    test('when unauthorized', () async {
      final statusesService = StatusesV1Service(
        instance: 'test',
        context: context.buildPostStub(
          'test',
          UserContext.oauth2Only,
          '/api/v1/statuses/1234/reblog',
          'test/src/service/v1/statuses/data/lookup_status.json',
          statusCode: 401,
        ),
      );

      expectUnauthorizedException(
        () async => await statusesService.reblogStatus(
          statusId: '1234',
        ),
      );
    });
  });

  group('.unreblogStatus', () {
    test('normal case', () async {
      final statusesService = StatusesV1Service(
        instance: 'test',
        context: context.buildPostStub(
          'test',
          UserContext.oauth2Only,
          '/api/v1/statuses/1234/unreblog',
          'test/src/service/v1/statuses/data/lookup_status.json',
        ),
      );

      final response = await statusesService.unreblogStatus(
        statusId: '1234',
      );

      expect(response, isA<MastodonResponse>());
      expect(response.rateLimit, isA<RateLimit>());
      expect(response.data, isA<Status>());
    });

    test('when unauthorized', () async {
      final statusesService = StatusesV1Service(
        instance: 'test',
        context: context.buildPostStub(
          'test',
          UserContext.oauth2Only,
          '/api/v1/statuses/1234/unreblog',
          'test/src/service/v1/statuses/data/lookup_status.json',
          statusCode: 401,
        ),
      );

      expectUnauthorizedException(
        () async => await statusesService.unreblogStatus(
          statusId: '1234',
        ),
      );
    });
  });

  group('.bookmarkStatus', () {
    test('normal case', () async {
      final statusesService = StatusesV1Service(
        instance: 'test',
        context: context.buildPostStub(
          'test',
          UserContext.oauth2Only,
          '/api/v1/statuses/1234/bookmark',
          'test/src/service/v1/statuses/data/lookup_status.json',
        ),
      );

      final response = await statusesService.bookmarkStatus(
        statusId: '1234',
      );

      expect(response, isA<MastodonResponse>());
      expect(response.rateLimit, isA<RateLimit>());
      expect(response.data, isA<Status>());
    });

    test('when unauthorized', () async {
      final statusesService = StatusesV1Service(
        instance: 'test',
        context: context.buildPostStub(
          'test',
          UserContext.oauth2Only,
          '/api/v1/statuses/1234/bookmark',
          'test/src/service/v1/statuses/data/lookup_status.json',
          statusCode: 401,
        ),
      );

      expectUnauthorizedException(
        () async => await statusesService.bookmarkStatus(
          statusId: '1234',
        ),
      );
    });
  });

  group('.unbookmarkStatus', () {
    test('normal case', () async {
      final statusesService = StatusesV1Service( 
        instance: 'test',
        context: context.buildPostStub(
          'test',
          UserContext.oauth2Only,
          '/api/v1/statuses/1234/unbookmark',
          'test/src/service/v1/statuses/data/lookup_status.json',
        ),
      );

      final response = await statusesService.unbookmarkStatus(
        statusId: '1234',
      );

      expect(response, isA<MastodonResponse>());
      expect(response.rateLimit, isA<RateLimit>());
      expect(response.data, isA<Status>());
    });

    test('when unauthorized', () async {
      final statusesService = StatusesV1Service(
        instance: 'test',
        context: context.buildPostStub(
          'test',
          UserContext.oauth2Only,
          '/api/v1/statuses/1234/unbookmark',
          'test/src/service/v1/statuses/data/lookup_status.json',
          statusCode: 401,
        ),
      );

      expectUnauthorizedException(
        () async => await statusesService.unbookmarkStatus(
          statusId: '1234',
        ),
      );
    });
  });

  group('.muteStatus', () {
    test('normal case', () async {
      final statusesService = StatusesV1Service( 
        instance: 'test',
        context: context.buildPostStub(
          'test',
          UserContext.oauth2Only,
          '/api/v1/statuses/1234/mute',
          'test/src/service/v1/statuses/data/lookup_status.json',
        ),
      );

      final response = await statusesService.muteStatus(
        statusId: '1234',
      );

      expect(response, isA<MastodonResponse>());
      expect(response.rateLimit, isA<RateLimit>());
      expect(response.data, isA<Status>());
    });

    test('when unauthorized', () async {
      final statusesService = StatusesV1Service(
        instance: 'test',
        context: context.buildPostStub(
          'test',
          UserContext.oauth2Only,
          '/api/v1/statuses/1234/mute',
          'test/src/service/v1/statuses/data/lookup_status.json',
          statusCode: 401,
        ),
      );

      expectUnauthorizedException(
        () async => await statusesService.muteStatus(
          statusId: '1234',
        ),
      );
    });
  });

  group('.unmuteStatus', () {
    test('normal case', () async {
      final statusesService = StatusesV1Service( 
        instance: 'test',
        context: context.buildPostStub(
          'test',
          UserContext.oauth2Only,
          '/api/v1/statuses/1234/unmute',
          'test/src/service/v1/statuses/data/lookup_status.json',
        ),
      );

      final response = await statusesService.unmuteStatus(
        statusId: '1234',
      );

      expect(response, isA<MastodonResponse>());
      expect(response.rateLimit, isA<RateLimit>());
      expect(response.data, isA<Status>());
    });

    test('when unauthorized', () async {
      final statusesService = StatusesV1Service(
        instance: 'test',
        context: context.buildPostStub(
          'test',
          UserContext.oauth2Only,
          '/api/v1/statuses/1234/unmute',
          'test/src/service/v1/statuses/data/lookup_status.json',
          statusCode: 401,
        ),
      );

      expectUnauthorizedException(
        () async => await statusesService.unmuteStatus(
          statusId: '1234',
        ),
      );
    });
  });

  group('.pinStatus', () {
    test('normal case', () async {
      final statusesService = StatusesV1Service( 
        instance: 'test',
        context: context.buildPostStub(
          'test',
          UserContext.oauth2Only,
          '/api/v1/statuses/1234/pin',
          'test/src/service/v1/statuses/data/lookup_status.json',
        ),
      );

      final response = await statusesService.pinStatus(
        statusId: '1234',
      );

      expect(response, isA<MastodonResponse>());
      expect(response.rateLimit, isA<RateLimit>());
      expect(response.data, isA<Status>());
    });

    test('when unauthorized', () async {
      final statusesService = StatusesV1Service(
        instance: 'test',
        context: context.buildPostStub(
          'test',
          UserContext.oauth2Only,
          '/api/v1/statuses/1234/pin',
          'test/src/service/v1/statuses/data/lookup_status.json',
          statusCode: 401,
        ),
      );

      expectUnauthorizedException(
        () async => await statusesService.pinStatus(
          statusId: '1234',
        ),
      );
    });
  });

  group('.unpinStatus', () {
    test('normal case', () async {
      final statusesService = StatusesV1Service( 
        instance: 'test',
        context: context.buildPostStub(
          'test',
          UserContext.oauth2Only,
          '/api/v1/statuses/1234/unpin',
          'test/src/service/v1/statuses/data/lookup_status.json',
        ),
      );

      final response = await statusesService.unpinStatus(
        statusId: '1234',
      );

      expect(response, isA<MastodonResponse>());
      expect(response.rateLimit, isA<RateLimit>());
      expect(response.data, isA<Status>());
    });

    test('when unauthorized', () async {
      final statusesService = StatusesV1Service(
        instance: 'test',
        context: context.buildPostStub(
          'test',
          UserContext.oauth2Only,
          '/api/v1/statuses/1234/unpin',
          'test/src/service/v1/statuses/data/lookup_status.json',
          statusCode: 401,
        ),
      );

      expectUnauthorizedException(
        () async => await statusesService.unpinStatus(
          statusId: '1234',
        ),
      );
    });
  });
  
}
