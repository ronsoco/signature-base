/*

   Generic Cloaking

   Florian Roth
   BSK Consulting GmbH

	License: Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
	Copyright and related rights waived via https://creativecommons.org/licenses/by-nc-sa/4.0/

*/

rule EXE_cloaked_as_TXT {
	meta:
		description = "Executable with TXT extension"
		author = "Florian Roth"
	condition:
		uint16(0) == 0x5a4d 					// Executable
		and filename matches /\.txt$/is   // TXT extension (case insensitive)
}

rule EXE_extension_cloaking {
	meta:
		description = "Executable showing different extension (Windows default 'hide known extension')"
		author = "Florian Roth"
	condition:
		filename matches /\.txt\.exe$/is or	// Special file extensions
		filename matches /\.pdf\.exe$/is		// Special file extensions
}

rule Cloaked_RAR_File {
	meta:
		description = "RAR file cloaked by a different extension"
		author = "Florian Roth"
	condition:
		uint32be(0) == 0x52617221							// RAR File Magic Header
		and not filename matches /(rarnew.dat|\.rar)$/is	// not the .RAR extension
		and not filepath contains "Recycle" 				// not a deleted RAR file in recycler
}

rule Base64_encoded_Executable {
	meta:
		description = "Detects an base64 encoded executable (often embedded)"
		author = "Florian Roth"
		date = "2015-05-28"
		score = 40
	strings:
		$s1 = "TVpTAQEAAAAEAAAA//8AALgAAAA" // 14 samples in goodware archive
		$s2 = "TVoAAAAAAAAAAAAAAAAAAAAAAAA" // 26 samples in goodware archive
		$s3 = "TVqAAAEAAAAEABAAAAAAAAAAAAA" // 75 samples in goodware archive
		$s4 = "TVpQAAIAAAAEAA8A//8AALgAAAA" // 168 samples in goodware archive
		$s5 = "TVqQAAMAAAAEAAAA//8AALgAAAA" // 28,529 samples in goodware archive
	condition:
		1 of them and not filepath contains "Thunderbird"
}

rule Binary_Drop_Certutil {
	meta:
		description = "Drop binary as base64 encoded cert trick"
		author = "Florian Roth"
		reference = "https://goo.gl/9DNn8q"
		date = "2015-07-15"
		score = 70
	strings:
		$s0 = "echo -----BEGIN CERTIFICATE----- >" ascii
		$s1 = "echo -----END CERTIFICATE----- >>" ascii
		$s2 = "certutil -decode " ascii
	condition:
		filesize < 10KB and all of them
}

rule StegoKatz {
	meta:
		description = "Encoded Mimikatz in other file types"
		author = "Florian Roth"
		reference = "https://goo.gl/jWPBBY"
		date = "2015-09-11"
		score = 70
	strings:
		$s1 = "VC92Ny9TSXZMNk5jLy8vOUlqUTFVRlFNQTZMLysvdjlJaTh2L0ZUNXJBUUJJaTFRa1NFaUx6K2hWSS8vL1NJME44bklCQU9pZC92Ny9USTJjSkpBQUFBQXp3RW1MV3hCSmkyc1lTWXR6S0VtTDQxL0R6TXhNaTl4SmlWc0lUWWxMSUUySlF4aFZWbGRCVkVGVlFWWkJWMGlCN1BBQUFBQklnMlFrYUFDNE1BQUFBRW1MNkVTTmNPQ0pSQ1JnaVVRa1pFbU5RN0JKaTlsTWpRWFBGQU1BU0ls" ascii
		$s2 = "Rpd3ovN3FlalVtNklLQ0xNNGtOV1BiY0VOVHROT0Zud25CWGN0WS9BcEdMR28rK01OWm85Nm9xMlNnY1U5aTgrSTBvNkFob1FOTzRHQWdtUElEVmlqald0Tk90b2FmN01ESWJUQkF5T0pYbTB4bFVHRTBZWEFWOXVoNHBkQnRrS0VFWWVBSEE2TDFzU0c5a2ZFTEc3QWd4WTBYY1l3ZzB6QUFXS09JZE9wQVhEK3lnS3lsR3B5Q1ljR1NJdFNseGZKWUlVVkNFdEZPVjRJUldERUl1QXpKZ2pCQWdsd0Va" ascii
	condition:
		filesize < 1000KB and 1 of them
}
