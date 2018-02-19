class EAD3Serializer < EADSerializer
  serializer_for :ead3

  def serialize_digital_object(digital_object, xml, fragments)
    return if digital_object["publish"] === false && !@include_unpublished
    return if digital_object["suppressed"] === true

    file_versions = digital_object['file_versions']
    title = digital_object['title']
    date = digital_object['dates'][0] || {}
    donotes = digital_object['notes'][0]

    atts = digital_object["publish"] === false ? {:audience => 'internal'} : {}

    content = ""
    content << title if title
    content << ": " if date['expression'] || date['begin']
    if date['expression']
      content << date['expression']
    elsif date['begin']
      content << date['begin']
      if date['end'] != date['begin']
        content << "-#{date['end']}"
      end
    end
    content << ". #{donotes['content'][0]}"

    atts['linktitle'] = digital_object['title'] if digital_object['title']

    if digital_object['digital_object_type']
      atts['daotype'] = 'otherdaotype'
      atts['otherdaotype'] = digital_object['digital_object_type']
    else
      atts['daotype'] = 'unknown'
    end

    if file_versions.empty?
      atts['href'] = digital_object['digital_object_id']
      atts['actuate'] = 'onrequest'
      atts['show'] = 'new'
      xml.dao(atts) {
        xml.descriptivenote { sanitize_mixed_content(content, xml, fragments, true) } if content
      }
    else
      file_versions.each do |file_version|
        atts['href'] = file_version['file_uri'] || digital_object['digital_object_id']
        atts['actuate'] = (file_version['xlink_actuate_attribute'].respond_to?(:downcase) && file_version['xlink_actuate_attribute'].downcase) || 'onrequest'
        atts['show'] = (file_version['xlink_show_attribute'].respond_to?(:downcase) && file_version['xlink_show_attribute'].downcase) || 'new'
        atts['localtype'] = file_version['use_statement'] if file_version['use_statement']
        atts['']
        xml.dao(atts) {
          xml.descriptivenote { sanitize_mixed_content(content, xml, fragments, true) } if content
        }
      end
    end
  end

end
