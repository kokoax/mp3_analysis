defmodule MP3Data do
  defstruct [:header, :frames, :sound_data]
  # defstruct [:tag, :version, :flg, :size, :data]
  def new(
  <<
  tag     :: bitstring-size(24),
  version :: bitstring-size(16),
  flg     :: bitstring-size(8),
  size    :: unsigned-integer-size(24),

  data    :: binary,
  >>) do
  %MP3Data{
    # data: data,
    header:     MP3Header.new(tag, version, flg, size),
    frames:     MP3Frames.new(data)
    sound_data: sound_data,
  }
  end
end

defmodule MP3Header do
  defstruct [:tag, :version, :flg, :size]
  def new(tag, version, flg, size) do
    %MP3Header{
      tag:     tag,
      version: version,
      flg:     flg,
      size:    size,
    }
  end
end

defmodule MP3Frames do
  defstruct [:title, :album, :artist, :comment, :genre]
  def new(
  <<
  all_data :: binary,
  >>) do
  %MP3Frames{
  }
  end
end

defmodule MP3Sound do
  defstruct [:sound_data]
  def new(
  size,
  <<
  frames     :: bitstring-size(10),
  sound_data :: binary,
  >>) do
  %MP3Sound{
    sound_data: sound_data,
  }
  end
end

[path] = System.argv

{:ok, file} = File.open path, [:read]
IO.inspect MP3Data.new IO.binread(file, :all)
# IO.inspect IO.binread(file, :all)
File.close file

