defmodule Wkhtmltopdf do
    @moduledoc """
      Provide function converto HTML documents to PDF 
      The command line [wkhtmltoPDF](http://wkhtmltopdf.org/) mus be installed and needs to be added 
      to your PATH

      ## Examples

        iex>Wkhtmltopdf.open("/tmp/page.html") |> Wkhtmltopdf.path("path/to/file.pdf") |> Wkhtmltopdf.command(:true)
        "wkhtmltopdf /tmp/page.html path/to/file.pdf"

        iex>Wkhtmltopdf.open("/tmp/page.html") |> Wkhtmltopdf.dpi(12) |> Wkhtmltopdf.orientation("Landscape") |> Wkhtmltopdf.path("path/to/file.pdf") |> Wkhtmltopdf.command(:true)
        "wkhtmltopdf --dpi 12 --orientation Landscape /tmp/page.html path/to/file.pdf"
    """
    @binary "wkhtmltopdf"

    import Supervisor.Spec

    def start(_type, _args) do
      children = [
        worker(Wkhtmltopdf.Runner, [], [name: Wkhtmltopdf.Runner])
      ]

      Supervisor.start_link(children, strategy: :one_for_one)
    end

    defmodule CommandNotFound do 
      defexception [:command]

      def message(%{command: command}) do
        "Comand not found #{command}"
      end
    end

    defmodule ExitException do
      defexception [:status]

      def message(%{status: status}) do
        "Exited with non-zero status (#{status})"
      end
    end

    @doc """
      Received path html file
    """
    def open(html_file) do
      unless File.exists?(html_file) do
        raise %ExitException{status: "File not found"}
      end
      
      [html_file]
    end

    @doc """
      Run command
    """
    def run([command|args]) do
      Wkhtmltopdf.Runner.exec command, args
      List.last(args)
    end

    @doc """
      Generate command and run
    """
    def run_command(opts) do
      [command|args] = command(opts)
      Wkhtmltopdf.Runner.exec command, args
      List.last(args)
    end

    @doc """
      Generate command and generate list
    """
    def command(opts) do
        Enum.concat(opts, [@binary])
             |> Enum.reverse()
    end

    @doc """
      Generate command string
    """
    def command(opts, :true) do
        Enum.concat(opts, [@binary])
             |> Enum.reverse()
             |> Enum.join(" ")
    end

    @doc """
      add pdf path with filename
    """
    def path(opts, pdf_path), do: [pdf_path, List.last(opts) | opts |> List.delete(List.last(opts))]

    @doc """
      Number of copies to print into the pdf file (default 1)
    """
    def copies(opts, number), do: [number, "--copies" | opts]

    @doc """
      Change the dpi explicitly (this has no effect on X11 based systems)  
    """
    def dpi(opts, number), do: [Integer.to_string(number), "--dpi" | opts]

    @doc """
      PDF will be generated in grayscale
    """
    def grayscale(opts), do: ["--grayscale" | opts]

    @doc """
      When embedding images scale them down to this dpi (default 600)
    """
    def image_dpi(opts, number), do: [Integer.to_string(number), "--image-dpi" | opts]

    @doc """
      When jpeg compressing images use this quality (default 94)
    """
    def image_quality(opts, number), do: [number, "--image-quality" | opts]

    @doc """
      Generates lower quality pdf/ps. Useful to shrink the result document space
    """
    def lowquality(opts), do: ["--lowquality" | opts]

    @doc """
      Set the page bottom margin
    """
    def margin_bottom(opts, unit), do: [ unit, "--margin-bottom" | opts]

    @doc """
      Set the page left margin (default 10mm)
    """
    def margin_left(opts, unit), do: [ unit, "--magin-left" | opts]

    @doc """
      Set the page right margin (default 10mm)
    """
    def margin_right(opts, unit), do: [ unit, "--margin-right" | opts]

    @doc """
      Set the page top margin
    """
    def margin_top(opts, unit), do: [ unit , "--margin-top" | opts]

    @doc """
      Set orientation to Landscape or Portrait (default Portrait)
    """
    def orientation(opts, type), do: [ type, "--orientation" | opts]

    @doc """
      Set paper size to: A4, Letter, etc. (default A4)
    """
    def page_size(opts, type), do: [ type, "--page-size" | opts]

    @doc """
      Do not print background
    """
    def no_background(opts), do: ["--no-background" | opts]

    @doc """
      Set an additional cookie (repeatable), value should be url encoded.
    """
    def cookie(opts, name, value), do: [ value, name, "--cookie"  | opts]

    @doc """
      Set an additional HTTP header (repeatable)
    """
    def custom_header(opts, name, value), do: [ value, name, "--custom-header" | opts]

    @doc """
      Wait some milliseconds for javascript finish (default 200)
    """
    def javascript_delay(opts, msec), do: [ msec, "--javascript-delay" | opts]

    @doc """
      HTTP Authentication username
    """
    def username(opts, username), do: [ username, "--username" | opts]

    @doc """
      HTTP Authentication password
    """
    def password(opts, pwd), do: [ pwd, "--password" | opts]

    @doc """
      Do not allow web pages to run javascript
    """
    def disable_javascript(opts), do: ["--disable-javascript" | opts]

    @doc """
      Add an additional post field (repeatable)
    """
    def post(opts, name, value), do: [ value, name, "--post" | opts]

    @doc """
      Post an additional file (repeatable)
    """
    def post_file(opts, name, path), do: [ path, name, "--post-file" | opts]

    @doc """
      Do not load or print images
    """
    def no_images(opts), do: ["--no-images" | opts]

end