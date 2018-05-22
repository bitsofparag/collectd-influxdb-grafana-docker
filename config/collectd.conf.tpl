#
# Config file for collectd(1).
# Please read collectd.conf(5) for a list of options.
# http://collectd.org/
#

# Metric                   CollectD Plugin Used
#-----------------------------------------------
# CPU                    - cpu, cpufreq, load
# Memory load            - memory
# CPU temperature        - thermal
# Storage load           - df
# Uptime                 - uptime
# Internet               - interface [eth0]
# Handle data            - rrd / network [InfluxDB - Grafana]
# Enclosure temperature  - TODO: connect an external temperature sensor

##############################################################################
# Global                                                                     #
#----------------------------------------------------------------------------#
# Global settings for the daemon.                                            #
##############################################################################

#Hostname    "localhost"
FQDNLookup   false
#BaseDir     "/var/lib/collectd"
#PIDFile     "/var/run/collectd.pid"
#PluginDir   "/usr/lib/collectd"
#TypesDB     "/usr/share/collectd/types.db"

#----------------------------------------------------------------------------#
# When enabled, internal statistics are collected, using "collectd" as the   #
# plugin name.                                                               #
# Disabled by default.                                                       #
#----------------------------------------------------------------------------#
CollectInternalStats true

#----------------------------------------------------------------------------#
# Interval at which to query values. This may be overwritten on a per-plugin #
# base by using the 'Interval' option of the LoadPlugin block:               #
#   <LoadPlugin foo>                                                         #
#       Interval 60                                                          #
#   </LoadPlugin>                                                            #
#----------------------------------------------------------------------------#
Interval     60

##############################################################################
# Logging                                                                    #
#----------------------------------------------------------------------------#
# Plugins which provide logging functions should be loaded first, so log     #
# messages generated when loading or configuring other plugins can be        #
# accessed.                                                                  #
##############################################################################

LoadPlugin logfile
LoadPlugin syslog

<Plugin logfile>
  LogLevel "info"
  File "/var/log/collectd.log"
</Plugin>

<Plugin syslog>
	LogLevel info
</Plugin>

##############################################################################
# LoadPlugin section                                                         #
#----------------------------------------------------------------------------#
# Lines beginning with a single `#' belong to plugins which have been built  #
# but are disabled by default.                                               #
#                                                                            #
# Lines begnning with `##' belong to plugins which have not been built due   #
# to missing dependencies or because they have been deactivated explicitly.  #
##############################################################################

LoadPlugin cpu
LoadPlugin cpufreq
LoadPlugin load
LoadPlugin memory
Loadplugin thermal

Loadplugin uuid

LoadPlugin df
LoadPlugin interface
LoadPlugin uptime
LoadPlugin users


#Loadplugin network
LoadPlugin write_http
LoadPlugin processes

##############################################################################
# Plugin configuration                                                       #
#----------------------------------------------------------------------------#
# In this section configuration stubs for each plugin are provided. A desc-  #
# ription of those options is available in the collectd.conf(5) manual page. #
##############################################################################

<Plugin cpu>
  ReportByCpu true
  ReportByState true
  ValuesPercentage true
	ReportNumCpu true
</Plugin>

<Plugin load>
  ReportRelative true
</Plugin>

<Plugin memory>
	ValuesAbsolute true
	ValuesPercentage false
</Plugin>

<Plugin df>
	Device "/dev/root"
	MountPoint "/"
	FSType "ext4"
	IgnoreSelected false
	ReportByDevice true
#	ReportReserved false
#	ReportInodes false
#	ValuesAbsolute true
#	ValuesPercentage false
</Plugin>

<Plugin interface>
	Interface "eth0"
	IgnoreSelected false
</Plugin>

# <Plugin uuid>
# 	UUIDFile "/etc/machine-id"
# </Plugin>

# <Plugin network>
#   Server "10.0.1.137" "25255"
# </Plugin>

<Plugin write_http>
  <Node "nginx_docker">
    URL "http://nginx.docker/api/metrics/"
    Format "JSON"
    User "%%%MONITORING_HOST%%%"
    Password "%%%MONITORING_PASS%%%"
    LogHttpError true
  </Node>
</Plugin>

# End