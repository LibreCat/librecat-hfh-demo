Demo application for HTML::FormHandler in future LibreCat
=========================================================

# Install

```
$ carton install
```

# Start

```
$ carton exec -- plackup bin/app.pl
```

Go to http://localhost:5000 in your browser

# HTML::FormHandler

This module makes intensively use of the perl package HTML::FormHanderl (HFH).
HFH handles both validation and rendering of HTML forms, but can be used outside
of the HTML context for validation.

For full documentation see [HTML::FormHandler](https://metacpan.org/pod/HTML::FormHandler)

## Validation

```

#initialize form with configured field definitions (see below)
my $form =  HTML::FormHandler->new( field_list => $field_list );

#process incoming request parameters. The parameter "posted" forces the validation even if "params" is an empty hash.
$form->process( posted => 1, params => $params );

#returns all errors as an array reference
$form->errors();

#returns errors for field "myfield"
$form->field("myfield")->errors();

#returns "filled in form values" as a hash reference
$form->fif();

```

#### Field list

Must be an array of objects, each of them containing the following attributes. Here we only list the attributes that relate to validation:

* **type**:
  * field type.
  * required
  * examples: "Text", "Select", "Number".
  * Corresponds by default to a perl package with perfix "HTML::FormHandler::Field"
  * additional attributes are determined by this field type.
* **name**:
  * html field name
  * required
* **required**:
  * determines that this parameter is mandatory
  * when not present the error message "required" is added to the list of errors
* **messages**:
  * hash reference that maps field specific error codes to human readable error messages

    e.g. "required" => "myfield must be given"
  * these messages can contain placeholders

    e.g. "required" => "[\_1] is required"

  * if the form has a language handle, the value of the mapping is localized

    e.g. "required" => "fields.myfield.messages.required"

  * one should consult the documentation to find out the specific error message for a field.

Example:

```
field_list:
  - name: first_name
    type: Text
    required: true
    messages:
      required: "Please provide your first name"
  - name: birth_year
    type: Integer
    #only enforced by the html input of type "number"
    range_start: 1900
    messages:
      integer_needed: "Birth year must be a integer number"

```

## Rendering

Each rendered form in HFH has the following structure:

```
FORM_WRAPPER_START
  FORM_START

    ELEMENT_WRAPPER_START

      ELEMENT_LABEL
      ELEMENT

    ELEMENT_WRAPPER_END

    [..]

  FORM_END
FORM_WRAPPER_END
```

#### element rendering

Each field type has a corresponding package for rendering in the namespace "HTML::FormHandler::Widget::Field".

e.g. field type "Text" is rendered by "HTML::FormHandler::Widget::Field::Text"

Configurable by the field definition attribute **widget**

#### label rendering

Configurable by the field definition attribute **label**

The text appears inside the html element "label" with the attribute "for" set to name of the element for focus.

If form has a language handle, the configured value is localized.

#### field wrapper

Both the label and the element can be wrapped inside an html element.

Corresponds to a package in the namespace "HTML::FormHandler::Widget::Wrapper"

Configurable by the field attribute **widget_wrapper**. Can also be set on form level, and be overridden for a specific field.

e.g.

When you set widget_wrapper on form level to "Bootstrap3", then each pair of label and element is wrapped inside a div with class "form-group"

#### Additional attributes

* **element_class**: list of css class classes (either as array or as string) for the element.

e.g. "form-control"

* **element_wrapper_class**: list of class classes for the wrapper

e.g. "form-group"

* **label_class**: list of class classes for the label

See [HTML::FormHandler rendering](https://metacpan.org/pod/release/GSHANK/HTML-FormHandler-0.40068/lib/HTML/FormHandler/Manual/Rendering.pod)
