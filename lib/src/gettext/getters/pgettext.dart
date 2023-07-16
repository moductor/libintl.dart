import "../lc.dart";
import "dcgettext.dart";
import "dgettext.dart";
import "gettext.dart";

/// Similar to [gettext] but allows to add context to the message.
String pgettext(String msgctxt, String msgid) => gettext(msgid);

/// Similar to [dgettext] but allows to add context to the message.
String dpgettext(String domainName, String msgctxt, String msgid) =>
    dgettext(domainName, msgid);

/// Similar to [dcgettext] but allows to add context to the message.
String dcpgettext(
        String domainName, String msgctxt, String msgid, LC category) =>
    dcgettext(domainName, msgid, category);
