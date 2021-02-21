#
# Postfix hashed maps maintenance
#
MAPS = aliases.db \
		sender_canonical.db recipient_canonical.db canonical.db \
		generic.db transport.db

all: $(MAPS)

# Mail aliases table
aliases.db: aliases.in
		@echo Rebuilding hashed DB for $@
		@postalias $<
		@mv $<.db $@

# All others
%.db: %.map
		@echo Rebuilding hashed DB for $@
		@postmap hash:$<
		@mv $<.db $@
