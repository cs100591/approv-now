import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'subscription_models.dart';

class SubscriptionRepository {
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> saveSubscription(Subscription subscription) async {
    final prefs = await _preferences;
    await prefs.setString('subscription_${subscription.userId}',
        jsonEncode(subscription.toJson()));
  }

  Future<Subscription?> getSubscription(String userId) async {
    final prefs = await _preferences;
    final subscriptionJson = prefs.getString('subscription_$userId');
    if (subscriptionJson == null) return null;

    try {
      return Subscription.fromJson(jsonDecode(subscriptionJson));
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteSubscription(String userId) async {
    final prefs = await _preferences;
    await prefs.remove('subscription_$userId');
  }
}
