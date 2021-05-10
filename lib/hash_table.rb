require 'pry'

class HashTable
  LOAD_FACTOR_LIMIT = 0.7
  BUCKET_SIZE_LIMIT = 3

  Element = Struct.new(:key, :value, :next, keyword_init: true)

  def initialize
    @storage = []
    @elements_count_in_storage = 0
    @storage_size = 8
    @max_bucket_size = 0
  end

  def [](key)
    element = @storage[bucket_for(key)]
    return if element.nil?
    if element.key == key
      element.value
    else
      find_value(element, key)
    end
  end

  def []=(key, value)
    rehash if load_factor_exceed?
    write(key, value)
  end

  private

  def find_value(element, key)
    return element.value if element.key == key
    return if element.next.nil?
    return find_value(element.next, key)
  end

  def bucket_for(key)
    key.hash % @storage_size
  end

  def load_factor_exceed?
    @max_bucket_size >= BUCKET_SIZE_LIMIT ||
     (@elements_count_in_storage.to_f / @storage.size.to_f) >= LOAD_FACTOR_LIMIT
  end

  def rehash
    @max_bucket_size = 0
    old_storage = @storage.dup
    @storage_size *= 2
    @elements_count_in_storage = 0
    @storage = Array.new(@storage_size * 2)
    old_storage.compact.each do |element| # => [Element#1,Element#2]
      loop do
        next_element = element.next
        write(element.key, element.value)
        break if next_element.nil?
        element = next_element
      end
    end
  end

  def write(key, value)
    bucket_number = bucket_for(key)
    element_in_bucket = @storage[bucket_number]
    new_element = Element.new(key: key, value: value)

    if element_in_bucket.nil?
      @storage[bucket_number] = new_element
      @elements_count_in_storage += 1
    elsif element_in_bucket.key == key
      @storage[bucket_number] = new_element
    elsif element_in_bucket.next.nil?
      @storage[bucket_number].next = new_element
    else
      last_element = traverse_list(element_in_bucket)
      last_element.next = new_element
      bucket_size = bucket_size_for(element_in_bucket)
      @max_bucket_size = [bucket_size, @max_bucket_size].max
    end
  end

  def bucket_size_for(start_element, size = 1)
    return size if start_element.next.nil?
    bucket_size_for(start_element.next, size += 1)
  end

  def traverse_list(list)
    return list if list.next.nil?

    traverse_list(list.next)
  end
end
