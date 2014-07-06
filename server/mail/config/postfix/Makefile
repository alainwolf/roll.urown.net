#
# Postfix hashed maps maintenance
#
MAPS = aliases.db canonical.db generic.db relay_password.db \
		sender_access.db sender_canonical.db 

all: $(MAPS)

# Mail aliases table
aliases.db: aliases.in
		@echo Rebuilding hashed DB for $@
		@postalias $<
		@mv $<.db $@

# All others
%.db: %.in
		@echo Rebuilding hashed DB for $@
		@postmap hash:$<
		@mv $<.db $@
