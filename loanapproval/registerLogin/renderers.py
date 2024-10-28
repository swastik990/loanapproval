from rest_framework.renderers import JSONRenderer

class UserRenderer(JSONRenderer):
    charset = 'utf-8'

    def render(self, data, accepted_media_type=None, renderer_context=None):
        # Check if there is an error in the response
        response = ''
        if 'ErrorDetail' in str(data):
            response = {
                'errors': data
            }
        else:
            response = {
                'data': data
            }

        return super(UserRenderer, self).render(response, accepted_media_type, renderer_context)
