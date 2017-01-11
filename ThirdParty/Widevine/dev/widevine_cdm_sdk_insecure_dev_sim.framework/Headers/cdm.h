// Copyright 2015 Google Inc. All Rights Reserved.
// Based on the EME draft spec from 2015 November 20.
// https://rawgit.com/w3c/encrypted-media/1dab9e5/index.html
#ifndef WVCDM_CDM_CDM_H_
#define WVCDM_CDM_CDM_H_

#if defined(_MSC_VER)
typedef unsigned char uint8_t;
typedef unsigned int uint32_t;
typedef int int32_t;
typedef __int64 int64_t;
#else
# include <stdint.h>
#endif

#include <map>
#include <string>

// Define CDM_EXPORT to export functionality across shared library boundaries.
#if defined(WIN32)
# if defined(CDM_IMPLEMENTATION)
#  define CDM_EXPORT __declspec(dllexport)
# else
#  define CDM_EXPORT __declspec(dllimport)
# endif  // defined(CDM_IMPLEMENTATION)
#else  // defined(WIN32)
# if defined(CDM_IMPLEMENTATION)
#  define CDM_EXPORT __attribute__((visibility("default")))
# else
#  define CDM_EXPORT
# endif
#endif  // defined(WIN32)

namespace widevine {

class CDM_EXPORT ITimerClient {
 public:
  // Called by ITimer when a timer expires.
  virtual void onTimerExpired(void* context) = 0;

 protected:
  ITimerClient() {}
  virtual ~ITimerClient() {}
};

class CDM_EXPORT Cdm : public ITimerClient {
 public:
  // Session types defined by EME.
  typedef enum {
    kTemporary = 0,
    kPersistentLicense = 1,
    kPersistent = kPersistentLicense,  // deprecated name from June 1 draft
    kPersistentUsageRecord = 2,
  } SessionType;

  // Message types defined by EME.
  typedef enum {
    kLicenseRequest = 0,
    kLicenseRenewal = 1,
    kLicenseRelease = 2,
    kIndividualizationRequest = 3,
  } MessageType;

  typedef enum {
    // These are defined by Widevine:
    kSuccess = 0,
    kNeedsDeviceCertificate = 1,
    kSessionNotFound = 2,
    kDecryptError = 3,
    kNoKey = 4,

    // These are analogous to the errors used by EME:
    kTypeError = 5,
    kInvalidAccess = kTypeError,  // deprecated name from June 1 draft
    kNotSupported = 6,
    kInvalidState = 7,
    kQuotaExceeded = 8,
    kRangeError = 9,

    // This covers errors that we do not expect (see logs for details):
    kUnexpectedError = 99999,
  } Status;

  // These are the init data types defined by EME.
  typedef enum {
    kCenc = 0,
    kKeyIds = 1,  // NOTE: not supported by Widevine at this time
    kWebM = 2,
  } InitDataType;

  // These are key statuses defined by EME.
  typedef enum {
    kUsable = 0,
    kExpired = 1,
    kOutputRestricted = 2,
    kOutputNotAllowed = kOutputRestricted,  // deprecated name from June 1 draft
    kStatusPending = 3,
    kInternalError = 4,
    kReleased = 5,
  } KeyStatus;

  // These are defined by Widevine.  The CDM can be configured to decrypt in
  // three modes (dependent on OEMCrypto support).
  typedef enum {
    // Data is decrypted to an opaque handle.
    // Translates to OEMCrypto's OEMCrypto_BufferType_Secure.
    kOpaqueHandle = 0,

    // Decrypted data never returned to the caller, but is decoded and rendered
    // by OEMCrypto.
    // Translates to OEMCrypto's OEMCrypto_BufferType_Direct.
    kDirectRender = 1,

    // There is no secure output available, so all data is decrypted into a
    // clear buffer in main memory.
    // Translates to OEMCrypto's OEMCrypto_BufferType_Clear.
    kNoSecureOutput = 2,
  } SecureOutputType;

  // Logging levels defined by Widevine.
  // See Cdm::initialize().
  typedef enum {
    kSilent = -1,
    kErrors = 0,
    kWarnings = 1,
    kInfo = 2,
    kDebug = 3,
    kVerbose = 4,
  } LogLevel;

  // A map of key statuses.
  // See Cdm::getKeyStatuses().
  typedef std::map<std::string, KeyStatus> KeyStatusMap;

  // An event listener interface provided by the application and attached to
  // each CDM session.
  // See Cdm::createSession().
  class IEventListener {
   public:
    // A URL to be added to a renewal request message.
    // This call will immediately precede the onMessage() call.
    // Do not override this call if the URL is not needed.
    //
    // WARNING: this call exists temporarily to allow interoperation with
    // older versions of Chromium and the prefixed EME API.  This call will
    // be removed in a future release.  Therefore: (1) Do not use this call
    // unless you are certain that it is needed on your platform for your
    // application, and (2) If it is needed, figure how move to a new version
    // of Chromium and the unprefixed EME API as soon as possible.
    // TODO: Remove this call (see b/24776024).
    virtual void onMessageUrl(const std::string& session_id,
                              const std::string& server_url) {}

    // A message (license request, renewal, etc.) to be dispatched to the
    // application's license server.
    // The response, if successful, should be provided back to the CDM via a
    // call to Cdm::update().
    virtual void onMessage(const std::string& session_id,
                           MessageType message_type,
                           const std::string& message) = 0;

    // There has been a change in the keys in the session or their status.
    virtual void onKeyStatusesChange(const std::string& session_id) = 0;

    // A remove() operation has been completed.
    virtual void onRemoveComplete(const std::string& session_id) = 0;

   protected:
    IEventListener() {}
    virtual ~IEventListener() {}
  };

  // A storage interface provided by the application, independent of CDM
  // instances.
  // See Cdm::initialize().
  // NOTE: It is important for users of your application to be able to clear
  // stored data.  Also, browsers or other multi-application systems should
  // store data separately per-app or per-origin.
  // See http://www.w3.org/TR/encrypted-media/#privacy-storedinfo.
  class IStorage {
   public:
    virtual bool read(const std::string& name,
                      std::string* data) = 0;
    virtual bool write(const std::string& name,
                       const std::string& data) = 0;
    virtual bool exists(const std::string& name) = 0;
    virtual bool remove(const std::string& name) = 0;
    virtual int32_t size(const std::string& name) = 0;

   protected:
    IStorage() {}
    virtual ~IStorage() {}
  };

  // A clock interface provided by the application, independent of CDM
  // instances.
  // See Cdm::initialize().
  class IClock {
   public:
    // Returns the current time in milliseconds since 1970 UTC.
    virtual int64_t now() = 0;

   protected:
    IClock() {}
    virtual ~IClock() {}
  };

  // A timer interface provided by the application, independent of CDM
  // instances.
  // See Cdm::initialize().
  class ITimer {
   public:
    // This typedef is for backward compatibility with v3.0.0.
    typedef ITimerClient IClient;

    // Call |client->onTimerExpired(context)| after a delay of |delay_ms| ms.
    virtual void setTimeout(int64_t delay_ms,
                            IClient* client,
                            void* context) = 0;

    // Cancel all timers associated with |client|.
    virtual void cancel(IClient *client) = 0;

   protected:
    ITimer() {}
    virtual ~ITimer() {}
  };

  // Client information, provided by the application, independent of CDM
  // instances.
  // See Cdm::initialize().
  // These parameters end up as client indentification in license requests.
  // All fields may be used by a license server proxy to drive business logic.
  // Some fields are required (indicated below), but please fill out as many
  // as make sense for your application.
  // No user-identifying information may be put in these fields!
  struct ClientInfo {
    // The name of the product or application, e.g. "TurtleTube"
    // Required.
    std::string product_name;

    // The name of the company who makes the device, e.g. "Kubrick, Inc."
    // Required.
    std::string company_name;

    // The name of the device, e.g. "HAL"
    std::string device_name;

    // The device model, e.g. "HAL 9000"
    // Required.
    std::string model_name;

    // The architecture of the device, e.g. "x86-64"
    std::string arch_name;

    // Information about the build of the browser, application, or platform into
    // which the CDM is integrated, e.g. "v2.71828, 2038-01-19-03:14:07"
    std::string build_info;
  };

  // Device certificate request information.
  // The structure is passed by the application to the library in as an output
  // parameter to Cdm::initialize().
  // All fields are filled in by the library to instruct the application to
  // handle device certificate requests, if needed.
  struct DeviceCertificateRequest {
    // If false, the library is ready to create and/or load sessions.
    // If true, a device certificate is needed first.
    // Sessions cannot be created or loaded until the device certificate has
    // been provisioned.
    bool needed;

    // If |needed| is true, this string contains the URL that must be used to
    // provision a device certificate.  The request must be a POST.
    std::string url;

    // If |needed| is true, the response from the above-described HTTP POST
    // must be provided as an argument to this method.
    // Returns kSuccess if the provisioning was successful.
    // Any other return value means the provisioning failed and the CDM cannot
    // be used yet.
    Status acceptReply(const std::string& reply);
  };

  // Initialize the CDM library and provide access to platform services.
  // All platform interfaces are required.
  // The |device_certificate_request| parameter will be filled in by
  // initialize().
  // See documentation for DeviceCertificateRequest for more information.
  // Logging is controlled by |verbosity|.
  // Must be called and must return kSuccess before create() is called.
  static Status initialize(
      SecureOutputType secure_output_type,
      const ClientInfo& client_info,
      IStorage* storage,
      IClock* clock,
      ITimer* timer,
      DeviceCertificateRequest* device_certificate_request,
      LogLevel verbosity);

  // Query the CDM library version.
  static const char* version();

  // Constructs a new CDM instance.
  // initialize() must be called first and must return kSuccess before a CDM
  // instance may be constructed.
  // The CDM may notify of events at any time via the provided |listener|,
  // which may not be NULL.
  // If |privacy_mode| is true, server certificates are required and will be
  // used to encrypt messages to the license server.
  // By using server certificates to encrypt communication with the license
  // server, device-identifying information cannot be extracted from the
  // license exchange process by an intermediate layer between the CDM and
  // the server.
  // This is particularly useful for browser environments, but is recommended
  // for use whenever possible.
  static Cdm* create(IEventListener* listener,
                     bool privacy_mode);

  virtual ~Cdm() {}

  // Provides a server certificate to be used to encrypt messages to the
  // license server.
  // If |privacy_mode| was true in create() and setServerCertificate() is not
  // called, the CDM will attempt to provision a server certificate through
  // IEventListener::onMessage() with messageType == kLicenseRequest.
  // May not be called if |privacy_mode| was false.
  virtual Status setServerCertificate(const std::string& certificate) = 0;

  // Creates a new session.
  // Do not use this to load an existing persistent session.
  // If successful, the session_id is returned via |sessionId|.
  virtual Status createSession(SessionType session_type,
                               std::string* session_id) = 0;

  // Generates a request based on the initData.
  // The request will be provided via a synchronous call to
  // IEventListener::onMessage().
  // This is done so that license requests and renewals follow the same flow.
  virtual Status generateRequest(const std::string& session_id,
                                 InitDataType init_data_type,
                                 const std::string& init_data) = 0;

  // Loads an existing persisted session from storage.
  virtual Status load(const std::string& session_id) = 0;

  // Provides messages, including licenses, to the CDM.
  // If the message is a successful response to a release message, stored
  // session data will be removed for the session.
  virtual Status update(const std::string& session_id,
                        const std::string& response) = 0;

  // The time, in milliseconds since 1970 UTC, after which the key(s) in the
  // session will no longer be usable to decrypt media data, or -1 if no such
  // time exists.
  virtual Status getExpiration(const std::string& session_id,
                               int64_t* expiration) = 0;

  // A map of known key IDs to the current status of the associated key.
  virtual Status getKeyStatuses(const std::string& session_id,
                                KeyStatusMap* key_statuses) = 0;

  // Indicates that the application no longer needs the session and the CDM
  // should release any resources associated with it and close it.
  // Does not generate release messages for persistent sessions.
  // Does not remove stored session data for persistent sessions.
  virtual Status close(const std::string& session_id) = 0;

  // Removes stored session data associated with the session.
  // The session must be loaded before it can be removed.
  // Generates release messages, which must be delivered to the license server.
  // A reply from the license server must be provided via update() before the
  // session is fully removed.
  virtual Status remove(const std::string& session_id) = 0;

  struct InputBuffer {
   public:
    InputBuffer()
      : key_id(NULL),
        key_id_length(0),
        iv(NULL),
        iv_length(0),
        data(NULL),
        data_length(0),
        block_offset(0),
        is_encrypted(true),
        is_video(true),
        first_subsample(true),
        last_subsample(true) {}

    const uint8_t* key_id;
    uint32_t key_id_length;

    // The IV is expected to be 16 bytes.
    const uint8_t* iv;
    uint32_t iv_length;

    const uint8_t* data;
    uint32_t data_length;

    // |data|'s offset within its 16-byte AES block, used for CENC subsamples.
    // Should start at 0 for each sample, then go up by |data_length| (mod 16)
    // after the |is_encrypted| part of each subsample.
    uint32_t block_offset;

    // If false, copies the input data directly to the output buffer.  Used for
    // secure output types, where the output buffer cannot be directly accessed
    // above the CDM.
    bool is_encrypted;

    // Used by secure output type kDirectRender, where the secure hardware must
    // decode and render the decrypted content:
    bool is_video;
    bool first_subsample;
    bool last_subsample;
  };

  struct OutputBuffer {
    OutputBuffer()
      : data(NULL),
        data_length(0),
        data_offset(0),
        is_secure(false) {}

    // If |is_secure| is false or the secure output type is kNoSecureOutput,
    // this is a memory address in main memory.
    // If |is_secure| is true and the secure output type is kOpaqueHandle,
    // this is an opaque handle.
    // If |is_secure| is true and the secure output type is kDirectRender,
    // this is ignored.
    // See also SecureOutputType argument to initialize().
    uint8_t* data;

    // The maximum amount of data that can be decrypted to the buffer in this
    // call, starting from |data|.
    // Must be at least as large as the input buffer's |data_length|.
    // This size accounts for the bytes that will be skipped by |data_offset|.
    uint32_t data_length;

    // An offset applied to the output address.
    // Useful when |data| is an opaque handle rather than an address.
    uint32_t data_offset;

    // False for clear buffers, true otherwise.
    // Must be false if the secure output type is kNoSecureOutput.
    // See also SecureOutputType argument to initialize().
    bool is_secure;
  };

  // Decrypt the input as described by |input| and pass the output as described
  // in |output|.
  virtual Status decrypt(const InputBuffer& input,
                         const OutputBuffer& output) = 0;

  // Sets a value in the custom app settings.  These are settings
  // that are sent with any message to the license server.  These methods
  // should only be used by advanced users maintaining existing systems.
  // The |key| cannot be empty.
  virtual Status setAppParameter(const std::string& key,
                                 const std::string& value) = 0;

  // Gets the current value in the custom app settings.  If the key is
  // not present, then kTypeError is returned.  The |key| cannot be
  // empty.  |result| cannot be null.  See setAppParameter().
  virtual Status getAppParameter(const std::string& key,
                                 std::string* result) = 0;

  // Removes the value in the custom app settings.  If the key is not
  // present, then kTypeError is returned.  The |key| cannot be empty.
  // See setAppParameter().
  virtual Status removeAppParameter(const std::string& key) = 0;

  // Clears all the values in the custom app settings.  See setAppParameter().
  virtual Status clearAppParameters() = 0;

 protected:
  Cdm() {}
};

}  // namespace widevine

#endif  // WVCDM_CDM_CDM_H_
