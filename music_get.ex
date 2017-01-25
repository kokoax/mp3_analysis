defmodule MP3Data do
  defstruct [:header, :frames, :sound_data]
  def new(
  <<
  tag     :: bitstring-size(24),
  version :: bitstring-size(16),
  flg     :: bitstring-size(8),
  size    :: unsigned-integer-size(32),
  data    :: binary,
  >>) do


  IO.puts version
  header               = MP3Header.getHeader(tag, version, flg, size)
  [frames, sound_data] = MP3Frames.getFrame(version, data)
  %MP3Data{
    header:     header,
    frames:     frames,
    sound_data: sound_data,
  }
  end
end

defmodule MP3Header do
  defstruct [:tag, :version, :flg, :size]
  def getHeader(tag, version, flg, size) do
    %MP3Header{
      tag:     tag,
      version: version,
      flg:     flg,
      size:    size,
    }
  end
end

defmodule MP3Frames do
  defp getFrameData(ver, size, next) when ver == << 3, 0 >>do
    # frame_size = (size-1) * 8
    <<
    _ :: bitstring-size(8),    # Frame body head's 1 byte is always nil so throw away
    data :: bitstring-size(size),
    other :: binary,
    >> = next
    ret_data = getFrame(ver,other)
    if ret_data == nil do
      IO.inspect other
      [data, nil, other]
    else
      [ret, sound_data] = ret_data
      [data, ret, sound_data]
    end
  end


  defp getFrameData(ver, size, next) when ver == << 2, 0 >>do
    # frame_size = (size-1) * 8
    <<
    _ :: bitstring-size(8),    # Frame body head's 1 byte is always nil so throw away
    data :: bitstring-size(size),
    _ :: bitstring-size(8),    # Frame body head's 1 byte is always nil so throw away
    other :: binary,
    >> = next
    ret_data = getFrame(ver,other)
    if ret_data == nil do
      IO.inspect other
      [data, nil, other]
    else
      [ret, sound_data] = ret_data
      [data, ret, sound_data]
    end
  end


  def getFrame(ver,
  <<
  tag  :: bitstring-size(32),
  size :: unsigned-integer-size(32),
  _    :: bitstring-size(16),
  next :: binary,
  >>) when ver == << 3, 0 >> do

  if Regex.match?(~r/^[0-9A-Z]+$/, tag) do
    [ret, map, sound_data] = getFrameData(ver, (size-1)*8, next)
    if map == nil do
      [%{tag => ret}, sound_data]
    else
      [Map.merge(%{tag => ret}, map), sound_data]
    end
  end
  end

  def getFrame(
  ver,
  <<
  tag  :: bitstring-size(24),
  size :: unsigned-integer-size(24),
  next :: binary,
  >>) when ver == << 2, 0 >> do

  if Regex.match?(~r/^[0-9A-Z]+$/, tag) do
    [ret, map, sound_data] = getFrameData(ver, (size-2)*8, next)
    if map == nil do
      [%{tag => ret}, sound_data]
    else
      [Map.merge(%{tag => ret}, map), sound_data]
    end
  end
  end
end

defmodule MP3Sound do
  def getSoundData(ver, size, data) when ver == << 3, 0 >> do
    frame_size = size * 8 * 10
    <<
    _          :: bitstring-size(frame_size),
    sound_data :: binary,
    >> = data
    sound_data
  end
  def getSoundData(ver, size, data) when ver == << 2, 0 >> do
    frame_size = size * 8 * 6
    <<
    _          :: bitstring-size(frame_size),
    sound_data :: binary,
    >> = data
    sound_data
  end
end

[path] = System.argv

{:ok, file} = File.open path, [:read]

music_data = MP3Data.new IO.binread(file, :all)

File.close file

{:ok, music_file} = File.open music_data.frames["TT2"], [:write]

IO.binwrite music_file, music_data.sound_data

File.close music_file

