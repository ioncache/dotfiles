# Copyright (c) 2006-2010 Jeremy Stanley <fungi@yuggoth.org>. Permission to
# use, copy, modify, and distribute this software is granted under terms
# provided in the LICENSE file distributed with this software.

"""Contains various object definitions needed by the weather utility."""

version = "1.5"

class Selections:
   """An object to contain selection data."""
   def __init__(self):
      """Store the config, options and arguments."""
      self.config = get_config()
      self.options, self.arguments = get_options(self.config)
      if self.arguments:
         self.arguments = [(x.lower()) for x in self.arguments]
      else: self.arguments = [ None ]
   def get(self, option, argument=None):
      """Retrieve data from the config or options."""
      if not argument: return self.options.__dict__[option]
      elif not self.config.has_section(argument):
         import sys
         sys.stderr.write("weather: error: no alias defined for " \
            + argument + "\n")
         sys.exit(1)
      elif self.config.has_option(argument, option):
         return self.config.get(argument, option)
      else: return self.options.__dict__[option]
   def get_bool(self, option, argument=None):
      """Get data and coerce to a boolean if necessary."""
      return bool(self.get(option, argument))

def bool(data):
   """Coerce data to a boolean value."""
   if type(data) is str:
      if eval(data): return True
      else: return False
   else:
      if data: return True
      else: return False

def quote(words):
   """Wrap a string in quotes if it contains spaces."""
   if words.find(" ") != -1: words = "\"" + words + "\""
   return words

def titlecap(words):
   """Perform English-language title capitalization."""
   words = words.lower().strip()
   for separator in [" ", "-", "'"]:
      newwords = []
      wordlist = words.split(separator)
      for word in wordlist:
         if word:
            newwords.append(word[0].upper() + word[1:])
      words = separator.join(newwords)
   end = len(words)
   for prefix in ["Mac", "Mc"]:
      position = 0
      offset = len(prefix)
      while position < end:
         position = words.find(prefix, position)
         if position == -1:
            position = end
         position += offset
         import string
         if position < end and words[position] in string.letters:
            words = words[:position] \
               + words[position].upper() \
               + words[position+1:]
   return words

def filter_units(line, units="imperial"):
   """Filter or convert units in a line of text between US/UK and metric."""
   import re
   # filter lines with both pressures in the form of "X inches (Y hPa)" or
   # "X in. Hg (Y hPa)"
   dual_p = re.match(
      "(.* )(\d*(\.\d+)? (inches|in\. Hg)) \((\d*(\.\d+)? hPa)\)(.*)",
      line
   )
   if dual_p:
      preamble, in_hg, i_fr, i_un, hpa, h_fr, trailer = dual_p.groups()
      if units == "imperial": line = preamble + in_hg + trailer
      elif units == "metric": line = preamble + hpa + trailer
   # filter lines with both temperatures in the form of "X F (Y C)"
   dual_t = re.match(
      "(.* )(\d*(\.\d+)? F) \((\d*(\.\d+)? C)\)(.*)",
      line
   )
   if dual_t:
      preamble, fahrenheit, f_fr, celsius, c_fr, trailer = dual_t.groups()
      if units == "imperial": line = preamble + fahrenheit + trailer
      elif units == "metric": line = preamble + celsius + trailer
   # if metric is desired, convert distances in the form of "X mile(s)" to
   # "Y kilometer(s)"
   if units == "metric":
      imperial_d = re.match(
         "(.* )(\d+)( mile\(s\))(.*)",
         line
      )
      if imperial_d:
         preamble, mi, m_u, trailer = imperial_d.groups()
         line = preamble + str(int(round(int(mi)*1.609344))) \
            + " kilometer(s)" + trailer
   # filter speeds in the form of "X MPH (Y KT)" to just "X MPH"; if metric is
   # desired, convert to "Z KPH"
   imperial_s = re.match(
      "(.* )(\d+)( MPH)( \(\d+ KT\))(.*)",
      line
   )
   if imperial_s:
      preamble, mph, m_u, kt, trailer = imperial_s.groups()
      if units == "imperial": line = preamble + mph + m_u + trailer
      elif units == "metric": 
         line = preamble + str(int(round(int(mph)*1.609344))) + " KPH" + \
            trailer
   # if imperial is desired, qualify given forcast temperatures like "X F"; if
   # metric is desired, convert to "Y C"
   imperial_t = re.match(
      "(.* )(High |high |Low |low )(\d+)(\.|,)(.*)",
      line
   )
   if imperial_t:
      preamble, parameter, fahrenheit, sep, trailer = imperial_t.groups()
      if units == "imperial":
         line = preamble + parameter + fahrenheit + " F" + sep + trailer
      elif units == "metric":
         line = preamble + parameter \
            + str(int(round((int(fahrenheit)-32)*5/9))) + " C" + sep + trailer
   # hand off the resulting line
   return line

def sorted(data):
   """Return a sorted copy of a list."""
   new_copy = data[:]
   new_copy.sort()
   return new_copy

def get_url(url, ignore_fail=False):
   """Return a string containing the results of a URL GET."""
   import urllib2
   try: return urllib2.urlopen(url).read()
   except urllib2.URLError:
      if ignore_fail: return ""
      else:
         import sys, traceback
         sys.stderr.write("weather: error: failed to retrieve\n   " \
            + url + "\n   " + \
            traceback.format_exception_only(sys.exc_type, sys.exc_value)[0])
         sys.exit(1)

def get_metar(
   id,
   verbose=False,
   quiet=False,
   headers=None,
   murl=None,
   imperial=False,
   metric=False
):
   """Return a summarized METAR for the specified station."""
   if not id:
      import sys
      sys.stderr.write("weather: error: id required for conditions\n")
      sys.exit(1)
   if not murl:
      murl = \
         "http://weather.noaa.gov/pub/data/observations/metar/decoded/%ID%.TXT"
   murl = murl.replace("%ID%", id.upper())
   murl = murl.replace("%Id%", id.capitalize())
   murl = murl.replace("%iD%", id)
   murl = murl.replace("%id%", id.lower())
   murl = murl.replace(" ", "_")
   metar = get_url(murl)
   if verbose: return metar
   else:
      lines = metar.split("\n")
      if not headers:
         headers = \
            "relative_humidity," \
            + "precipitation_last_hour," \
            + "sky conditions," \
            + "temperature," \
            + "weather," \
            + "wind"
      headerlist = headers.lower().replace("_"," ").split(",")
      output = []
      if not quiet:
         title = "Current conditions at %s"
         place = lines[0].split(", ")
         if len(place) > 1:
            place = "%s, %s (%s)" % (titlecap(place[0]), place[1], id.upper())
         else: place = id.upper()
         output.append(title%place)
         output.append("Last updated " + lines[1])
      for header in headerlist:
         for line in lines:
            if line.lower().startswith(header + ":"):
               if line.endswith(":0") or line.endswith(":1"):
                  line = line[:-2]
               if imperial: line = filter_units(line, units="imperial")
               elif metric: line = filter_units(line, units="metric")
               if quiet: output.append(line)
               else: output.append("   " + line)
      return "\n".join(output)

def get_alert(
   zone,
   verbose=False,
   quiet=False,
   atype=None,
   aurl=None,
   imperial=False,
   metric=False
):
   """Return alert notice for the specified zone and type."""
   if not zone:
      import sys
      sys.stderr.write("weather: error: zone required for alerts\n")
      sys.exit(1)
   if not atype: atype = "severe_weather_stmt"
   if not aurl:
      aurl = \
         "http://weather.noaa.gov/pub/data/watches_warnings/%atype%/%zone%.txt"
   aurl = aurl.replace("%ATYPE%", atype.upper())
   aurl = aurl.replace("%Atype%", atype.capitalize())
   aurl = aurl.replace("%atypE%", atype)
   aurl = aurl.replace("%atype%", atype.lower())
   aurl = aurl.replace("%ZONE%", zone.upper())
   aurl = aurl.replace("%Zone%", zone.capitalize())
   aurl = aurl.replace("%zonE%", zone)
   aurl = aurl.replace("%zone%", zone.lower())
   aurl = aurl.replace(" ", "_")
   alert = get_url(aurl, ignore_fail=True).strip()
   if alert:
      if verbose: return alert
      else:
         lines = alert.split("\n")
         muted = True
         import calendar, re, time
         valid_time = time.strftime("%Y%m%d%H%M")
         #if not quiet: output = [ lines[3], lines[5] ]
         #if not quiet: output = [ lines[8], lines[10] ]
         #else: output = []
         output = []
         for line in lines:
            if line.startswith("Expires:") and "Expires:"+valid_time > line:
               return ""
            if muted and line.find("...") != -1:
               muted = False
            if line == "$$" \
               or line.startswith("LAT...LON") \
               or line.startswith("TIME...MOT...LOC"):
               muted = True
            if line and not (
               muted \
               or line == "&&"
               or re.match("^/.*/$", line) \
               or re.match("^"+zone.split("/")[1][:3].upper()+".*", line)
            ):
               if quiet: output.append(line)
               else: output.append("   " + line)
         return "\n".join(output)

def get_forecast(
   city,
   st,
   verbose=False,
   quiet=False,
   flines="0",
   furl=None,
   imperial=False,
   metric=False
):
   """Return the forecast for a specified city/st combination."""
   if not city or not st:
      import sys
      sys.stderr.write("weather: error: city and st required for forecast\n")
      sys.exit(1)
   if not furl:
      furl = "http://weather.noaa.gov/pub/data/forecasts/city/%st%/%city%.txt"
   furl = furl.replace("%CITY%", city.upper())
   furl = furl.replace("%City%", city.capitalize())
   furl = furl.replace("%citY%", city)
   furl = furl.replace("%city%", city.lower())
   furl = furl.replace("%ST%", st.upper())
   furl = furl.replace("%St%", st.capitalize())
   furl = furl.replace("%sT%", st)
   furl = furl.replace("%st%", st.lower())
   furl = furl.replace(" ", "_")
   forecast = get_url(furl)
   if verbose: return forecast
   else:
      lines = forecast.split("\n")
      output = []
      if not quiet: output += lines[2:4]
      flines = int(flines)
      if not flines: flines = len(lines) - 5
      for line in lines[5:flines+5]:
         if imperial: line = filter_units(line, units="imperial")
         elif metric: line = filter_units(line, units="metric")
         if line.startswith("."):
            if quiet: output.append(line.replace(".", "", 1))
            else: output.append(line.replace(".", "   ", 1))
      return "\n".join(output)

def get_options(config):
   """Parse the options passed on the command line."""

   # for optparse's builtin -h/--help option
   usage = "usage: %prog [ options ] [ alias [ alias [...] ] ]"

   # for optparse's builtin --version option
   verstring = "%prog " + version

   # create the parser
   import optparse
   option_parser = optparse.OptionParser(usage=usage, version=verstring)

   # the -a/--alert option
   if config.has_option("default", "alert"):
      default_alert = bool(config.get("default", "alert"))
   else: default_alert = False
   option_parser.add_option("-a", "--alert",
      dest="alert",
      action="store_true",
      default=default_alert,
      help="include local alert notices")

   # the --atypes option
   if config.has_option("default", "atypes"):
      default_atypes = config.get("default", "atypes")
   else:
      default_atypes = \
         "flash_flood/statement," \
         + "flash_flood/warning," \
         + "flash_flood/watch," \
         + "flood/coastal," \
         + "flood/statement," \
         + "flood/warning," \
         + "non_precip," \
         + "severe_weather_stmt," \
         + "special_weather_stmt," \
         + "thunderstorm," \
         + "tornado," \
         + "urgent_weather_message"
   option_parser.add_option("--atypes",
      dest="atypes",
      default=default_atypes,
      help="alert notification types to display")

   # the --aurl option
   if config.has_option("default", "aurl"):
      default_aurl = config.get("default", "aurl")
   else:
      default_aurl = \
         "http://weather.noaa.gov/pub/data/watches_warnings/%atype%/%zone%.txt"
   option_parser.add_option("--aurl",
      dest="aurl",
      default=default_aurl,
      help="alert URL (including %atype% and %zone%)")

   # separate options object from list of arguments and return both
   # the -c/--city option
   if config.has_option("default", "city"):
      default_city = config.get("default", "city")
   else: default_city = ""
   option_parser.add_option("-c", "--city",
      dest="city",
      default=default_city,
      help="the city name (ex: \"Raleigh Durham\")")

   # the --flines option
   if config.has_option("default", "flines"):
      default_flines = config.get("default", "flines")
   else: default_flines = "0"
   option_parser.add_option("--flines",
      dest="flines",
      default=default_flines,
      help="maximum number of forecast lines to show")

   # the -f/--forecast option
   if config.has_option("default", "forecast"):
      default_forecast = bool(config.get("default", "forecast"))
   else: default_forecast = False
   option_parser.add_option("-f", "--forecast",
      dest="forecast",
      action="store_true",
      default=default_forecast,
      help="include a local forecast")

   # the --furl option
   if config.has_option("default", "furl"):
      default_furl = config.get("default", "furl")
   else:
      default_furl = \
         "http://weather.noaa.gov/pub/data/forecasts/city/%st%/%city%.txt"
   option_parser.add_option("--furl",
      dest="furl",
      default=default_furl,
      help="forecast URL (including %city% and %st%)")

   # the --headers option
   if config.has_option("default", "headers"):
      default_headers = config.get("default", "headers")
   else:
      default_headers = \
         "temperature," \
         + "relative_humidity," \
         + "wind," \
         + "weather," \
         + "sky_conditions," \
         + "precipitation_last_hour"
   option_parser.add_option("--headers",
      dest="headers",
      default=default_headers,
      help="the conditions headers to display")

   # the -i/--id option
   if config.has_option("default", "id"):
      default_id = config.get("default", "id")
   else: default_id = ""
   option_parser.add_option("-i", "--id",
      dest="id",
      default=default_id,
      help="the METAR station ID (ex: KRDU)")

   # the --imperial option
   if config.has_option("default", "imperial"):
      default_imperial = bool(config.get("default", "imperial"))
   else: default_imperial = False
   option_parser.add_option("--imperial",
      dest="imperial",
      action="store_true",
      default=default_imperial,
      help="filter/convert for US/UK units")

   # the -l/--list option
   option_parser.add_option("-l", "--list",
      dest="list",
      action="store_true",
      default=False,
      help="print a list of configured aliases")

   # the -m/--metric option
   if config.has_option("default", "metric"):
      default_metric = bool(config.get("default", "metric"))
   else: default_metric = False
   option_parser.add_option("-m", "--metric",
      dest="metric",
      action="store_true",
      default=default_metric,
      help="filter/convert for metric units")

   # the --murl option
   if config.has_option("default", "murl"):
      default_murl = config.get("default", "murl")
   else:
      default_murl = \
         "http://weather.noaa.gov/pub/data/observations/metar/decoded/%ID%.TXT"
   option_parser.add_option("--murl",
      dest="murl",
      default=default_murl,
      help="METAR URL (including %id%)")

   # the -n/--no-conditions option
   if config.has_option("default", "conditions"):
      default_conditions = bool(config.get("default", "conditions"))
   else: default_conditions = True
   option_parser.add_option("-n", "--no-conditions",
      dest="conditions",
      action="store_false",
      default=default_conditions,
      help="disable output of current conditions (forces -f)")

   # the -o/--omit-forecast option
   option_parser.add_option("-o", "--omit-forecast",
      dest="forecast",
      action="store_false",
      default=default_forecast,
      help="omit the local forecast (cancels -f)")

   # the -q/--quiet option
   if config.has_option("default", "quiet"):
      default_quiet = bool(config.get("default", "quiet"))
   else: default_quiet = False
   option_parser.add_option("-q", "--quiet",
      dest="quiet",
      action="store_true",
      default=default_quiet,
      help="skip preambles and don't indent")

   # the -s/--st option
   if config.has_option("default", "st"):
      default_st = config.get("default", "st")
   else: default_st = ""
   option_parser.add_option("-s", "--st",
      dest="st",
      default=default_st,
      help="the state abbreviation (ex: NC)")

   # the -v/--verbose option
   if config.has_option("default", "verbose"):
      default_verbose = bool(config.get("default", "verbose"))
   else: default_verbose = False
   option_parser.add_option("-v", "--verbose",
      dest="verbose",
      action="store_true",
      default=default_verbose,
      help="show full decoded feeds (cancels -q)")

   # the -z/--zones option
   if config.has_option("default", "zones"):
      default_zones = config.get("default", "zones")
   else: default_zones = ""
   option_parser.add_option("-z", "--zones",
      dest="zones",
      default=default_zones,
      help="alert zones (ex: nc/ncc183,nc/ncz041)")

   options, arguments = option_parser.parse_args()
   return options, arguments

def get_config():
   """Parse the aliases and configuration."""
   import ConfigParser
   config = ConfigParser.ConfigParser()
   import os.path
   rcfiles = [
      "/etc/weatherrc",
      os.path.expanduser("~/.weatherrc"),
      "weatherrc"
      ]
   import os
   for rcfile in rcfiles:
      if os.access(rcfile, os.R_OK): config.read(rcfile)
   for section in config.sections():
      if section != section.lower():
         if config.has_section(section.lower()):
            config.remove_section(section.lower())
         config.add_section(section.lower())
         for option,value in config.items(section):
            config.set(section.lower(), option, value)
   return config

def list_aliases(config):
   """Return a formatted list of aliases defined in the config."""
   sections = []
   for section in sorted(config.sections()):
      if section.lower() not in sections and section != "default":
         sections.append(section.lower())
   output = "configured aliases..."
   for section in sorted(sections):
      output += "\n   " \
         + section \
         + ": --id=" \
         + quote(config.get(section, "id")) \
         + " --city=" \
         + quote(config.get(section, "city")) \
         + " --st=" \
         + quote(config.get(section, "st"))
   return output

