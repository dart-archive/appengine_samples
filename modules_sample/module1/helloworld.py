# Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
# for details. All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.

import webapp2

class MainPage(webapp2.RequestHandler):
    def get(self):
        self.response.headers['Content-Type'] = 'text/plain'
        self.response.write(
          'Hello from Python module (%s).' % self.request.environ['PATH_INFO'])

application = webapp2.WSGIApplication([
    ('/.*', MainPage),
], debug=True)
