import '../../models/referral.dart';
import '../../core/utils/logger.dart';

/// Service for SMS Fallback transmission.
///
/// CRITICAL PRIVACY RULE:
/// Do NOT send full sensitive clinical information or diagnoses through plain SMS.
/// Plain SMS is unencrypted. Use minimal referral tokens and IDs only.
class SmsService {
  /// Encodes a referral into a compact, privacy-safe SMS fallback payload.
  /// Format: RELYCARE#<TOKEN>#<SRC_FACILITY>#<DEST_FACILITY>#<PATIENT_INITIALS>#<URGENCY>
  String generateSmsPayload(Referral referral) {
    final initials = referral.patient != null && referral.patient!.fullName.isNotEmpty
        ? referral.patient!.fullName.split(' ').map((e) => e[0].toUpperCase()).join('')
        : 'PT';

    final payload = 'RELYCARE#${referral.referralToken}#${referral.sourceFacilityId}#'
        '${referral.destinationFacilityId}#$initials#${referral.urgency.name.toUpperCase()}';

    AppLogger.info('Generated safe SMS payload: $payload', 'SmsService');
    return payload;
  }

  /// Sends the SMS fallback message via the SMS gateway / native SMS intent.
  Future<bool> sendFallbackSms({
    required String recipientPhoneNumber,
    required Referral referral,
  }) async {
    final payload = generateSmsPayload(referral);
    AppLogger.info('Dispatching SMS fallback to $recipientPhoneNumber: $payload', 'SmsService');

    // TODO (SMS Specialist): Integrate native telephony channel or Twilio / SMS Gateway API.
    return true;
  }

  // TODO: Add SMS payload parsing method for incoming fallback messages.
}
