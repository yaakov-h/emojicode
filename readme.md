# Emojicode

So I had a crazy idea one night. PGP-encrypted ciphertext can grow quite large. Twitter only allows for 140 characters.

But Twitter allows for 140 *characters* - not *bytes*. If we could encode the ciphertext into enough characters, we could compress more than 140 bytes into a single tweet.

This project uses unicode characters including Emoji to pack 10 bits into a single output character, which lets you send 175 bytes of data in a single tweet.

This is not practically useful.