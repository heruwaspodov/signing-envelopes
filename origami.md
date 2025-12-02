# Origami Research

```rb
puts "Generating a RSA key pair."
key = OpenSSL::PKey::RSA.new 2048

puts "Generating a self-signed certificate."
name = OpenSSL::X509::Name.parse 'CN=origami/DC=example'

cert = OpenSSL::X509::Certificate.new
cert.version = 2
cert.serial = 0
cert.not_before = Time.now
cert.not_after = Time.now + 3600

cert.public_key = key.public_key
cert.subject = name

extension_factory = OpenSSL::X509::ExtensionFactory.new nil, cert

cert.add_extension extension_factory.create_extension('basicConstraints', 'CA:TRUE', true)
cert.add_extension extension_factory.create_extension('keyUsage', 'digitalSignature')
cert.add_extension extension_factory.create_extension('subjectKeyIdentifier', 'hash')

cert.issuer = name
cert.sign key, OpenSSL::Digest::SHA256.new

include Origami

OUTPUT_FILE = "testing.pdf"

# Create the PDF contents
contents = ContentStream.new.setFilter(:FlateDecode)
contents.write OUTPUT_FILE,
    x: 350, y: 750, rendering: Text::Rendering::STROKE, size: 30

pdf = PDF.new
page = Page.new.setContents(contents)
pdf.append_page(page)

sig_annot = Annotation::Widget::Signature.new
sig_annot.Rect = Rectangle[llx: 89.0, lly: 386.0, urx: 190.0, ury: 353.0]

page.add_annotation(sig_annot)

# Sign the PDF with the specified keys
pdf.sign(cert, key,
    method: 'adbe.pkcs7.detached',
    annotation: sig_annot,
    location: "France",
    contact: "gdelugre@localhost",
    reason: "Signature sample"
)

# Save the resulting file
pdf.save(OUTPUT_FILE)

puts "PDF file saved as #{OUTPUT_FILE}."
```

# Generate self-signed certificate using cloudhsm
```rb
require 'openssl'
require 'time'

OpenSSL::Engine.load
e = OpenSSL::Engine.by_id("cloudhsm")
e.set_default(OpenSSL::Engine::METHOD_ALL)

PKEY = File.read "/opt/cloudhsm/etc/app-private-key.pem" # Load fake private key
key = OpenSSL::PKey::RSA.new(PKEY) # Load fake private key

name = OpenSSL::X509::Name.parse 'C=Indonesia/CN=Mekari Identitas Digital/DC=Mekari/O=Mekari Sign/OU=Engineering/ST=DKI Jakarta'
cert = OpenSSL::X509::Certificate.new
cert.version = 2
cert.serial = 0
cert.not_before = Time.now
cert.not_after = Time.now + 3600

cert.public_key = key.public_key
cert.subject = name

extension_factory = OpenSSL::X509::ExtensionFactory.new nil, cert
cert.issuer = name

cert.add_extension extension_factory.create_extension('basicConstraints', 'CA:TRUE', true)
cert.add_extension extension_factory.create_extension('keyUsage', 'digitalSignature')
cert.add_extension extension_factory.create_extension('subjectKeyIdentifier', 'hash')
cert.sign key, OpenSSL::Digest::SHA256.new

OpenSSL::Engine.cleanup
puts "#{cert}"
```

# Sign pdf using HSM fake key and self-signed certificate
```rb
require 'openssl'
require 'time'
require 'origami'
include Origami

# Origami patch module
module Origami
    class Date < LiteralString
      def self.parse(str)
        unless str =~ REGEXP_TOKEN
          raise InvalidDateError,
                'Not a valid Date string'
        end

        date =
          {
            year: $LAST_MATCH_INFO['year'].to_i
          }

        date[:month] = $LAST_MATCH_INFO['month'].to_i if $LAST_MATCH_INFO['month']
        date[:day] = $LAST_MATCH_INFO['day'].to_i if $LAST_MATCH_INFO['day']
        date[:hour] = $LAST_MATCH_INFO['hour'].to_i if $LAST_MATCH_INFO['hour']
        date[:min] = $LAST_MATCH_INFO['min'].to_i if $LAST_MATCH_INFO['min']
        date[:sec] = $LAST_MATCH_INFO['sec'].to_i if $LAST_MATCH_INFO['sec']

        if %w[+ -].include?($LAST_MATCH_INFO['ut'])
          utc_offset = $LAST_MATCH_INFO['ut_hour_off'].to_i * 3600 + $LAST_MATCH_INFO['ut_min_off'].to_i * 60
          utc_offset = -utc_offset if $LAST_MATCH_INFO['ut'] == '-'

          date[:utc_offset] = utc_offset
        end

        Origami::Date.new(**date)
      end

      def self.now
        now = Time.now.utc

        date =
          {
            year: now.strftime('%Y').to_i,
            month: now.strftime('%m').to_i,
            day: now.strftime('%d').to_i,
            hour: now.strftime('%H').to_i,
            min: now.strftime('%M').to_i,
            sec: now.strftime('%S').to_i,
            utc_offset: now.utc_offset
          }

        Origami::Date.new(**date)
      end
    end
end


FILE = "testing.pdf"

# Create the PDF contents
contents = ContentStream.new.setFilter(:FlateDecode)
contents.write FILE,
    x: 350, y: 750, rendering: Text::Rendering::STROKE, size: 30

pdf = PDF.new
page = Page.new.setContents(contents)
pdf.append_page(page)

sign_annotation = Annotation::Widget::Signature.new
sign_annotation.Rect = Rectangle[llx: 89.0, lly: 386.0, urx: 190.0, ury: 353.0]

page.add_annotation(sign_annotation)

# Load cloudhsm openssl engine
OpenSSL::Engine.load

e = OpenSSL::Engine.by_id("cloudhsm")
e.set_default(OpenSSL::Engine::METHOD_ALL)

PKEY = File.read "/opt/cloudhsm/etc/app-private-key.pem" # Load fake private key
CA_CRT = File.read "/opt/cloudhsm/etc/cert.crt" # Load self signed CA
PRIVATE_KEY = OpenSSL::PKey::RSA.new(PKEY) # Load fake private key
CA_CERT = OpenSSL::X509::Certificate.new(CA_CRT) # Load self signed CA

puts "#{PRIVATE_KEY}" # Print fake private key
puts "#{CA_CERT}"

pdf.sign(CA_CERT, PRIVATE_KEY,
    method: 'adbe.pkcs7.detached',
    annotation: sign_annotation,
    location: "Indonesia",
    contact: "mekari-esign@mekari.com",
    reason: "Mekari Sign"
)

# Save the resulting file
pdf.save("testing_signed.pdf")

OpenSSL::Engine.cleanup

# Cleanup engine
puts "PDF file saved as #{FILE}."
```

# Sign pdf using GlobalSign cert intermediate

```ruby
require 'openssl'
require 'time'
require 'origami'
include Origami

# Origami patch module
module Origami
    class Date < LiteralString
      def self.parse(str)
        unless str =~ REGEXP_TOKEN
          raise InvalidDateError,
                'Not a valid Date string'
        end

        date =
          {
            year: $LAST_MATCH_INFO['year'].to_i
          }

        date[:month] = $LAST_MATCH_INFO['month'].to_i if $LAST_MATCH_INFO['month']
        date[:day] = $LAST_MATCH_INFO['day'].to_i if $LAST_MATCH_INFO['day']
        date[:hour] = $LAST_MATCH_INFO['hour'].to_i if $LAST_MATCH_INFO['hour']
        date[:min] = $LAST_MATCH_INFO['min'].to_i if $LAST_MATCH_INFO['min']
        date[:sec] = $LAST_MATCH_INFO['sec'].to_i if $LAST_MATCH_INFO['sec']

        if %w[+ -].include?($LAST_MATCH_INFO['ut'])
          utc_offset = $LAST_MATCH_INFO['ut_hour_off'].to_i * 3600 + $LAST_MATCH_INFO['ut_min_off'].to_i * 60
          utc_offset = -utc_offset if $LAST_MATCH_INFO['ut'] == '-'

          date[:utc_offset] = utc_offset
        end

        Origami::Date.new(**date)
      end

      def self.now
        now = Time.now.utc

        date =
          {
            year: now.strftime('%Y').to_i,
            month: now.strftime('%m').to_i,
            day: now.strftime('%d').to_i,
            hour: now.strftime('%H').to_i,
            min: now.strftime('%M').to_i,
            sec: now.strftime('%S').to_i,
            utc_offset: now.utc_offset
          }

        Origami::Date.new(**date)
      end
    end
end


FILE = "testing.pdf"

# Create the PDF contents
contents = ContentStream.new.setFilter(:FlateDecode)
contents.write FILE,
    x: 350, y: 750, rendering: Text::Rendering::STROKE, size: 30

pdf = PDF.new
page = Page.new.setContents(contents)
pdf.append_page(page)

sign_annotation = Annotation::Widget::Signature.new
sign_annotation.Rect = Rectangle[llx: 89.0, lly: 386.0, urx: 190.0, ury: 353.0]

page.add_annotation(sign_annotation)

OpenSSL::Engine.load
e = OpenSSL::Engine.by_id("cloudhsm")
e.set_default(OpenSSL::Engine::METHOD_ALL)

PKEY = File.read "/opt/cloudhsm/etc/app-private-key.pem"
PRIVATE_KEY = OpenSSL::PKey::RSA.new(PKEY)

rootPem = File.read "/opt/cloudhsm/etc/globalsign-cert.crt"
root_pem = OpenSSL::X509::Certificate.new(rootPem)

intermediateOne = File.read "/opt/cloudhsm/etc/globalsign-intermediate1.crt"
intermediate_one = OpenSSL::X509::Certificate.new(intermediateOne)

intermediateTwo = File.read "/opt/cloudhsm/etc/globalsign-intermediate2.crt"
intermediate_two = OpenSSL::X509::Certificate.new(intermediateTwo)

pdf.sign(root_pem, PRIVATE_KEY,
    method: 'adbe.pkcs7.detached',
    annotation: sign_annotation,
    ca: [intermediate_one, intermediate_two],
    location: "Indonesia",
    contact: "mekari-esign@mekari.com",
    reason: "Mekari Sign"
)

pdf.save("signed.pdf")
OpenSSL::Engine.cleanup
puts "PDF file saved as #{FILE}."
```


# Sign pdf using GlobalSign cert intermediate - Open existing PDF

```ruby
require 'openssl'
require 'time'
require 'origami'
include Origami

# Origami patch module
module Origami
    class Date < LiteralString
      def self.parse(str)
        unless str =~ REGEXP_TOKEN
          raise InvalidDateError,
                'Not a valid Date string'
        end

        date =
          {
            year: $LAST_MATCH_INFO['year'].to_i
          }

        date[:month] = $LAST_MATCH_INFO['month'].to_i if $LAST_MATCH_INFO['month']
        date[:day] = $LAST_MATCH_INFO['day'].to_i if $LAST_MATCH_INFO['day']
        date[:hour] = $LAST_MATCH_INFO['hour'].to_i if $LAST_MATCH_INFO['hour']
        date[:min] = $LAST_MATCH_INFO['min'].to_i if $LAST_MATCH_INFO['min']
        date[:sec] = $LAST_MATCH_INFO['sec'].to_i if $LAST_MATCH_INFO['sec']

        if %w[+ -].include?($LAST_MATCH_INFO['ut'])
          utc_offset = $LAST_MATCH_INFO['ut_hour_off'].to_i * 3600 + $LAST_MATCH_INFO['ut_min_off'].to_i * 60
          utc_offset = -utc_offset if $LAST_MATCH_INFO['ut'] == '-'

          date[:utc_offset] = utc_offset
        end

        Origami::Date.new(**date)
      end

      def self.now
        now = Time.now.utc

        date =
          {
            year: now.strftime('%Y').to_i,
            month: now.strftime('%m').to_i,
            day: now.strftime('%d').to_i,
            hour: now.strftime('%H').to_i,
            min: now.strftime('%M').to_i,
            sec: now.strftime('%S').to_i,
            utc_offset: now.utc_offset
          }

        Origami::Date.new(**date)
      end
    end
end

pdf = PDF.read('unsigned.pdf', lazy: true)
sign_annotation = Annotation::Widget::Signature.new
sign_annotation.Rect = Rectangle[llx: 0, lly: 0, urx: 0, ury: 0]
pdf.pages.first.add_annotation(sign_annotation)

OpenSSL::Engine.load
e = OpenSSL::Engine.by_id("cloudhsm")
e.set_default(OpenSSL::Engine::METHOD_ALL)

PKEY = File.read "/opt/cloudhsm/etc/app-private-key.pem"
PRIVATE_KEY = OpenSSL::PKey::RSA.new(PKEY)

rootPem = File.read "/opt/cloudhsm/etc/globalsign-cert.crt"
root_pem = OpenSSL::X509::Certificate.new(rootPem)

intermediateOne = File.read "/opt/cloudhsm/etc/globalsign-intermediate1.crt"
intermediate_one = OpenSSL::X509::Certificate.new(intermediateOne)

intermediateTwo = File.read "/opt/cloudhsm/etc/globalsign-intermediate2.crt"
intermediate_two = OpenSSL::X509::Certificate.new(intermediateTwo)

pdf.sign(root_pem, PRIVATE_KEY,
    method: 'adbe.pkcs7.detached',
    ca: [intermediate_one, intermediate_two],
    annotation: sign_annotation,
    location: "Indonesia",
    contact: "mekari-esign@mekari.com",
    reason: "Mekari Sign"
)

pdf.save("signed.pdf")
OpenSSL::Engine.cleanup
puts "PDF file saved as #{FILE}."
```
