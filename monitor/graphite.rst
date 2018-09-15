:orphan:

.. image:: graphite-logo.*
    :alt: Graphite Logo
    :align: right


Collecting Metrics
==================

.. contents::
  :local:


`Graphite <https://graphiteapp.org/>`_ is an enterprise-ready monitoring tool
that runs equally well on cheap hardware or Cloud infrastructure. Teams use
Graphite to track the performance of their websites, applications, business
services, and networked servers. It marked the start of a new generation of
monitoring tools, making it easier than ever to store, retrieve, share, and
visualize time-series data.

Graphite consists of three software components:

 #. carbon - a high-performance service that listens for time-series data
 #. whisper - a simple database library for storing time-series data
 #. graphite-web - Graphite's user interface & API for rendering graphs and dashboards

Metrics get fed into the stack via the **Carbon** service, which writes the data
out to **Whisper** databases for long-term storage. Users interact with the
**Graphite web UI** or API, which in turn queries **Carbon** and **Whisper** for
the data needed to construct the requested graphs.

Graphite's web platform offers a variety of output styles and formats, including
raw images, CSV, XML, and JSON, allowing anyone to easily embed custom graphs in
other web pages or dashboards.


Installation Options
--------------------

As with other Python web applications, there are numerous ways to install and
run them. The official documentation lists some of them. In this document we
stick to the following:

 * We install using :file:`pip` - the Python package manager.
 * We use Python virtual environments (:file:`virtualenv`).
 * The web front-end is served by uwSGI.
 * The uwSGI application is managed by :file:`systemd`.
 * Nginx is used as reverse-proxy in front of the uwSGI application.


Prerequisites
-------------

 * Python 2.7 (Python 3 support is still experimental)
 * Virtualenv
 * Cairo 2D graphics library development files
 * Foreign function interface library development files
 * MariaDB database server
 * Memcached  - distributed general-purpose memory caching system
 * uWSGI - the Web Server Gateway Interface (WSGI)
 * Nginx web server


Prerequisites Installation
^^^^^^^^^^^^^^^^^^^^^^^^^^

Install the required Ubuntu packages and :file:`pip`::

	$ sudo -i
	$ apt install python-dev libcairo2-dev libffi-dev build-essential
	$ pip install --upgrade pip virtualenv


Create and start the virtual environment::

	$ virtualenv /opt/graphite
	$ source /opt/graphite/bin/activate


The prompt in your terminal changes to indicate that you are working in a
virtual environment now.


Carbon and Whisper
------------------

Is the part who listens for incoming data.

Carbon Installation
^^^^^^^^^^^^^^^^^^^

We install Carbon using :file:`pip`::

	$ pip install --upgrade https://github.com/graphite-project/carbon/tarball/master


Whisper Installation
^^^^^^^^^^^^^^^^^^^^

Whisper stores the received data in the database.

Whisper is always installed in :file:`/usr/local/bin`. There are now options to
change that.

We install Carbon using :file:`pip`::

	$ pip install --upgrade https://github.com/graphite-project/whisper/tarball/master


Carbon Configuration
^^^^^^^^^^^^^^^^^^^^

::

	$ mkdir -p /etc/carbon
	$ cp /opt/graphite/conf/carbon.conf.example /opt/graphite/conf/carbon.conf


Edit the configuration file :file:`/opt/graphite/conf/carbon.conf` as follows:

.. code-block:: ini

	[cache]
	# Configure carbon directories.
	#
	# OS environment variables can be used to tell carbon where graphite is
	# installed, where to read configuration from and where to write data.
	#
	#   GRAPHITE_ROOT        - Root directory of the graphite installation.
	#                          Defaults to ../
	#   GRAPHITE_CONF_DIR    - Configuration directory (where this file lives).
	#                          Defaults to $GRAPHITE_ROOT/conf/
	#   GRAPHITE_STORAGE_DIR - Storage directory for whisper/rrd/log/pid files.
	#                          Defaults to $GRAPHITE_ROOT/storage/
	#
	STORAGE_DIR    = /var/lib/graphite/
	LOCAL_DATA_DIR = /var/lib/graphite/whisper
	WHITELISTS_DIR = /var/lib/graphite/lists/
	CONF_DIR       = /etc/carbon
	LOG_DIR        = /var/log/carbon
	PID_DIR        = /run

	# Specify the database library used to store metric data on disk. Each database
	# may have configurable options to change the behaviour of how it writes to
	# persistent storage.
	#
	# whisper - Fixed-size database, similar in design and purpose to RRD. This is
	# the default storage backend for carbon and the most rigorously tested.
	DATABASE = whisper

	# Enable daily log rotation. If disabled, carbon will automatically re-open
	# the file if it's rotated out of place (e.g. by logrotate daemon)
	ENABLE_LOGROTATION = True

	# Specify the user to drop privileges to
	# If this is blank carbon runs as the user that invokes it
	# This user must have write access to the local data directory
	USER = _graphite

	# Limit the size of the cache to avoid swapping or becoming CPU bound.
	# Sorts and serving cache queries gets more expensive as the cache grows.
	# Use the value "inf" (infinity) for an unlimited cache size.
	MAX_CACHE_SIZE = inf

	# Limits the number of whisper update_many() calls per second, which effectively
	# means the number of write requests sent to the disk. This is intended to
	# prevent over-utilizing the disk and thus starving the rest of the system.
	# When the rate of required updates exceeds this, then carbon's caching will
	# take effect and increase the overall throughput accordingly.
	MAX_UPDATES_PER_SECOND = 500

	# If defined, this changes the MAX_UPDATES_PER_SECOND in Carbon when a
	# stop/shutdown is initiated.  This helps when MAX_UPDATES_PER_SECOND is
	# relatively low and carbon has cached a lot of updates; it enables the carbon
	# daemon to shutdown more quickly.
	# MAX_UPDATES_PER_SECOND_ON_SHUTDOWN = 1000

	# Softly limits the number of whisper files that get created each minute.
	# Setting this value low (e.g. 50) is a good way to ensure that your carbon
	# system will not be adversely impacted when a bunch of new metrics are
	# sent to it. The trade off is that any metrics received in excess of this
	# value will be silently dropped, and the whisper file will not be created
	# until such point as a subsequent metric is received and fits within the
	# defined rate limit. Setting this value high (like "inf" for infinity) will
	# cause carbon to create the files quickly but at the risk of increased I/O.
	MAX_CREATES_PER_MINUTE = 50

	# Set the minimum timestamp resolution supported by this instance. This allows
	# internal optimisations by overwriting points with equal truncated timestamps
	# in order to limit the number of updates to the database. It defaults to one
	# second.
	MIN_TIMESTAMP_RESOLUTION = 1

	# Set the minimum lag in seconds for a point to be written to the database in
	# order to optimize batching. This means that each point will wait at least the
	# duration of this lag before being written. Setting this to 0 disable the
	# feature. This currently only works when using the timesorted write strategy.
	# MIN_TIMESTAMP_LAG = 0

	# Set the interface and port for the line (plain text) listener.  Setting the
	# interface to 0.0.0.0 listens on all interfaces.  Port can be set to 0 to
	# disable this listener if it is not required.
	LINE_RECEIVER_INTERFACE = 127.0.0.1
	LINE_RECEIVER_PORT = 2003

	# Set this to True to enable the UDP listener. By default this is off
	# because it is very common to run multiple carbon daemons and managing
	# another (rarely used) port for every carbon instance is not fun.
	ENABLE_UDP_LISTENER = False
	UDP_RECEIVER_INTERFACE = 127.0.0.1
	UDP_RECEIVER_PORT = 2003

	# Set the interface and port for the pickle listener.  Setting the interface to
	# 0.0.0.0 listens on all interfaces.  Port can be set to 0 to disable this
	# listener if it is not required.
	PICKLE_RECEIVER_INTERFACE = 127.0.0.1
	PICKLE_RECEIVER_PORT = 2004

	# Set the interface and port for the protobuf listener.  Setting the interface
	# to 0.0.0.0 listens on all interfaces.  Port can be set to 0 to disable this
	# listener if it is not required.
	# PROTOBUF_RECEIVER_INTERFACE = 127.0.0.1
	# PROTOBUF_RECEIVER_PORT = 2005

	# Limit the number of open connections the receiver can handle as any time.
	# Default is no limit. Setting up a limit for sites handling high volume
	# traffic may be recommended to avoid running out of TCP memory or having
	# thousands of TCP connections reduce the throughput of the service.
	#MAX_RECEIVER_CONNECTIONS = inf

	# Per security concerns outlined in Bug #817247 the pickle receiver
	# will use a more secure and slightly less efficient unpickler.
	# Set this to True to revert to the old-fashioned insecure unpickler.
	USE_INSECURE_UNPICKLER = False

	CACHE_QUERY_INTERFACE = 127.0.0.1
	CACHE_QUERY_PORT = 7002

	# Set this to False to drop datapoints received after the cache
	# reaches MAX_CACHE_SIZE. If this is True (the default) then sockets
	# over which metrics are received will temporarily stop accepting
	# data until the cache size falls below 95% MAX_CACHE_SIZE.
	USE_FLOW_CONTROL = True

	# If enabled this setting is used to timeout metric client connection if no
	# metrics have been sent in specified time in seconds
	#METRIC_CLIENT_IDLE_TIMEOUT = None

	# By default, carbon-cache will log every whisper update and cache hit.
	# This can be excessive and degrade performance if logging on the same
	# volume as the whisper data is stored.
	LOG_UPDATES = False
	LOG_CREATES = False
	LOG_CACHE_HITS = False
	LOG_CACHE_QUEUE_SORTS = False

	# The thread that writes metrics to disk can use one of the following strategies
	# determining the order in which metrics are removed from cache and flushed to
	# disk. The default option preserves the same behavior as has been historically
	# available in version 0.9.10.
	#
	# sorted - All metrics in the cache will be counted and an ordered list of
	# them will be sorted according to the number of datapoints in the cache at the
	# moment of the list's creation. Metrics will then be flushed from the cache to
	# disk in that order.
	#
	# timesorted - All metrics in the list will be looked at and sorted according
	# to the timestamp of there datapoints. The metric that were the least recently
	# written will be written first. This is an hybrid strategy between max and
	# sorted which is particularly adapted to sets of metrics with non-uniform
	# resolutions.
	#
	# max - The writer thread will always pop and flush the metric from cache
	# that has the most datapoints. This will give a strong flush preference to
	# frequently updated metrics and will also reduce random file-io. Infrequently
	# updated metrics may only ever be persisted to disk at daemon shutdown if
	# there are a large number of metrics which receive very frequent updates OR if
	# disk i/o is very slow.
	#
	# naive - Metrics will be flushed from the cache to disk in an unordered
	# fashion. This strategy may be desirable in situations where the storage for
	# whisper files is solid state, CPU resources are very limited or deference to
	# the OS's i/o scheduler is expected to compensate for the random write
	# pattern.
	#
	CACHE_WRITE_STRATEGY = sorted

	# On some systems it is desirable for whisper to write synchronously.
	# Set this option to True if you'd like to try this. Basically it will
	# shift the onus of buffering writes from the kernel into carbon's cache.
	WHISPER_AUTOFLUSH = False

	# By default new Whisper files are created pre-allocated with the data region
	# filled with zeros to prevent fragmentation and speed up contiguous reads and
	# writes (which are common). Enabling this option will cause Whisper to create
	# the file sparsely instead. Enabling this option may allow a large increase of
	# MAX_CREATES_PER_MINUTE but may have longer term performance implications
	# depending on the underlying storage configuration.
	# WHISPER_SPARSE_CREATE = False

	# Only beneficial on linux filesystems that support the fallocate system call.
	# It maintains the benefits of contiguous reads/writes, but with a potentially
	# much faster creation speed, by allowing the kernel to handle the block
	# allocation and zero-ing. Enabling this option may allow a large increase of
	# MAX_CREATES_PER_MINUTE. If enabled on an OS or filesystem that is unsupported
	# this option will gracefully fallback to standard POSIX file access methods.
	WHISPER_FALLOCATE_CREATE = True

	# --------------------------------------------------------------------------#


Don't bother with the other sections besides "[cache]" for now.


Carbon System Service
^^^^^^^^^^^^^^^^^^^^^

Although we would prefer a native systemd service, Carbon installs itself in
:file:`/etc/init.d/carbon-cache`, which then gets picked up by systemd::

	$ systemctl status carbon-cache.service


Graphite-Web
------------

Graphite's user interface & API for rendering graphs and dashboards is a Python
Django application.


Graphite-Web Installation
^^^^^^^^^^^^^^^^^^^^^^^^^

::

	$ pip install https://github.com/graphite-project/graphite-web/tarball/master


Graphite-Web Configuration
^^^^^^^^^^^^^^^^^^^^^^^^^^

::

	$ cp /opt/webapp/graphite/local_settings.py.example \
		/etc/graphite/local_settings.py


Edit the configuration file :file:`/etc/graphite/local_settings.py` as follows:


Graphite Database Setup
^^^^^^^^^^^^^^^^^^^^^^^

Although the Graphite data itself is handled by Carbon and the whisper database
library, the web application is a Django Python application, and needs to store
its data somewhere.


Graphite-Web uwSGI Configuration
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^



Graphite-Web Systemd Service
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Edit the Systemd file :file:`/etc/systemd/system/carbon.service` as follows:

.. code-block:: ini

	...


Web Server Configuration
------------------------



References
----------

 * `Graphite Documentation <https://graphite.readthedocs.io/en/latest/>`_
